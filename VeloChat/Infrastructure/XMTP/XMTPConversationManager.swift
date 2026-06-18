import Foundation
import AVFoundation
import XMTPiOS

enum ConversationKindInfo {
    case group
    case dm
}

struct ConversationSummaryInfo {
    let id: String
    let kind: ConversationKindInfo
    let title: String
    let lastMessagePreview: String?
    let lastActivityDate: Date
    let peerInboxId: String?
    let lastMessageSenderInboxId: String?
    let lastMessageIsFromMe: Bool
}

struct GroupInfoData {
    let name: String
    let announcement: String
}

struct GroupMemberInfo {
    let inboxId: String
    let isMe: Bool
}

struct NicknameUpdateInfo {
    let inboxId: String
    let nickname: String
}

struct MessageEventInfo {
    let conversationId: String
    let isFromMe: Bool
    let nicknameUpdate: NicknameUpdateInfo?
}

struct ChatMessageInfo {
    let id: String
    let text: String
    let isFromMe: Bool
    let isSystemNotice: Bool
    let senderInboxId: String
    let nicknameUpdate: NicknameUpdateInfo?
    let imageData: Data?
    let audioData: Data?
    let audioDuration: TimeInterval?
    let sentAt: Date
    let sentAtNs: Int64
}

enum ConversationManagerError: LocalizedError {
    case conversationNotFound
    case notAGroup

    var errorDescription: String? {
        switch self {
        case .conversationNotFound:
            return "未找到该会话"
        case .notAGroup:
            return "该会话不是群组"
        }
    }
}

protocol XMTPConversationManaging {
    func fetchConversations() async throws -> [ConversationSummaryInfo]
    func fetchConversation(conversationId: String) async throws -> ConversationSummaryInfo?
    func startConversation(peerInboxId: String) async throws -> ConversationSummaryInfo
    func fetchMessages(conversationId: String, beforeNs: Int64?) async throws -> [ChatMessageInfo]
    func sendMessage(conversationId: String, text: String) async throws -> ChatMessageInfo
    func sendImage(conversationId: String, imageData: Data, filename: String, mimeType: String) async throws -> ChatMessageInfo
    func sendVoiceMessage(conversationId: String, audioData: Data, filename: String, mimeType: String, duration: TimeInterval) async throws -> ChatMessageInfo
    func streamMessages(conversationId: String) -> AsyncThrowingStream<ChatMessageInfo, Error>
    func streamAllMessages() -> AsyncThrowingStream<MessageEventInfo, Error>
    func createGroup(name: String, peerInboxIds: [String]) async throws -> ConversationSummaryInfo
    func pushTopics(forConversationIds conversationIds: [String]) async throws -> [String]
    func fetchGroupInfo(conversationId: String) async throws -> GroupInfoData
    func updateGroupAnnouncement(conversationId: String, announcement: String) async throws
    func updateGroupName(conversationId: String, name: String) async throws
    func fetchGroupMembers(conversationId: String) async throws -> [GroupMemberInfo]
    func updateMyNickname(conversationId: String, nickname: String) async throws -> NicknameUpdateInfo
}

final class XMTPConversationManager: XMTPConversationManaging {
    private let clientManager: XMTPClientManaging

    init(clientManager: XMTPClientManaging) {
        self.clientManager = clientManager
    }

    func fetchConversations() async throws -> [ConversationSummaryInfo] {
        let client = try await clientManager.currentClient()
        _ = try await client.conversations.syncAllConversations()

        let conversations = try await client.conversations.list(
            consentStates: [.allowed, .unknown]
        )

        var summaries: [ConversationSummaryInfo] = []
        for conversation in conversations {
            summaries.append(try await summary(for: conversation, currentInboxId: client.inboxID))
        }
        return summaries
    }

    func fetchConversation(conversationId: String) async throws -> ConversationSummaryInfo? {
        let client = try await clientManager.currentClient()
        guard let conversation = try await client.conversations.findConversation(conversationId: conversationId) else {
            return nil
        }
        try await conversation.sync()
        return try await summary(for: conversation, currentInboxId: client.inboxID)
    }

    func startConversation(peerInboxId: String) async throws -> ConversationSummaryInfo {
        let client = try await clientManager.currentClient()
        let conversation = try await client.conversations.newConversation(with: peerInboxId)
        return try await summary(for: conversation, currentInboxId: client.inboxID)
    }

    func fetchMessages(conversationId: String, beforeNs: Int64?) async throws -> [ChatMessageInfo] {
        let client = try await clientManager.currentClient()
        guard let conversation = try await client.conversations.findConversation(conversationId: conversationId) else {
            throw ConversationManagerError.conversationNotFound
        }
        try await conversation.sync()
        let isGroup = Self.isGroup(conversation)
        let messages: [DecodedMessage]
        if let beforeNs {
            messages = Array(try await conversation.messages(limit: 15, beforeNs: beforeNs, direction: .descending).reversed())
        } else {
            messages = Array(try await conversation.messages(limit: 30, direction: .descending).reversed())
        }
        return messages.compactMap { map($0, conversationId: conversationId, currentInboxId: client.inboxID, isGroup: isGroup) }
    }

    func sendMessage(conversationId: String, text: String) async throws -> ChatMessageInfo {
        let client = try await clientManager.currentClient()
        guard let conversation = try await client.conversations.findConversation(conversationId: conversationId) else {
            throw ConversationManagerError.conversationNotFound
        }
        let messageId = try await conversation.send(text: text)
        return ChatMessageInfo(id: messageId, text: text, isFromMe: true, isSystemNotice: false, senderInboxId: client.inboxID, nicknameUpdate: nil, imageData: nil, audioData: nil, audioDuration: nil, sentAt: Date(), sentAtNs: Int64(Date().timeIntervalSince1970 * 1_000_000_000))
    }

    func sendImage(conversationId: String, imageData: Data, filename: String, mimeType: String) async throws -> ChatMessageInfo {
        let client = try await clientManager.currentClient()
        guard let conversation = try await client.conversations.findConversation(conversationId: conversationId) else {
            throw ConversationManagerError.conversationNotFound
        }
        let attachment = Attachment(filename: filename, mimeType: mimeType, data: imageData)
        let messageId = try await conversation.send(content: attachment, options: SendOptions(contentType: ContentTypeAttachment))
        return ChatMessageInfo(
            id: messageId,
            text: "",
            isFromMe: true,
            isSystemNotice: false,
            senderInboxId: client.inboxID,
            nicknameUpdate: nil,
            imageData: imageData,
            audioData: nil,
            audioDuration: nil,
            sentAt: Date(), sentAtNs: Int64(Date().timeIntervalSince1970 * 1_000_000_000)
        )
    }

    func sendVoiceMessage(conversationId: String, audioData: Data, filename: String, mimeType: String, duration: TimeInterval) async throws -> ChatMessageInfo {
        let client = try await clientManager.currentClient()
        guard let conversation = try await client.conversations.findConversation(conversationId: conversationId) else {
            throw ConversationManagerError.conversationNotFound
        }
        let attachment = Attachment(filename: filename, mimeType: mimeType, data: audioData)
        let messageId = try await conversation.send(content: attachment, options: SendOptions(contentType: ContentTypeAttachment))
        return ChatMessageInfo(
            id: messageId,
            text: "",
            isFromMe: true,
            isSystemNotice: false,
            senderInboxId: client.inboxID,
            nicknameUpdate: nil,
            imageData: nil,
            audioData: audioData,
            audioDuration: duration,
            sentAt: Date(), sentAtNs: Int64(Date().timeIntervalSince1970 * 1_000_000_000)
        )
    }

    func streamMessages(conversationId: String) -> AsyncThrowingStream<ChatMessageInfo, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    let client = try await self.clientManager.currentClient()
                    guard let conversation = try await client.conversations.findConversation(conversationId: conversationId) else {
                        continuation.finish(throwing: ConversationManagerError.conversationNotFound)
                        return
                    }
                    let isGroup = Self.isGroup(conversation)
                    for try await message in conversation.streamMessages() {
                        if let info = self.map(message, conversationId: conversationId, currentInboxId: client.inboxID, isGroup: isGroup) {
                            continuation.yield(info)
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    func streamAllMessages() -> AsyncThrowingStream<MessageEventInfo, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    let client = try await self.clientManager.currentClient()
                    for try await message in client.conversations.streamAllMessages() {
                        print("[streamAllMessages] conversationId=\(message.conversationId) senderInboxId=\(message.senderInboxId) id=\(message.id)")
                        let isFromMe = message.senderInboxId == client.inboxID
                        var nicknameUpdate: NicknameUpdateInfo?
                        if (try? message.encodedContent.type) == ContentTypeMemberNickname,
                           let nickname: String = try? message.content(), !nickname.isEmpty {
                            nicknameUpdate = NicknameUpdateInfo(inboxId: message.senderInboxId, nickname: nickname)
                        }
                        continuation.yield(MessageEventInfo(conversationId: message.conversationId, isFromMe: isFromMe, nicknameUpdate: nicknameUpdate))
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    func createGroup(name: String, peerInboxIds: [String]) async throws -> ConversationSummaryInfo {
        let client = try await clientManager.currentClient()
        let group = try await client.conversations.newGroup(
            with: peerInboxIds,
            permissions: .allMembers,
            name: name
        )
        return try await summary(for: .group(group), currentInboxId: client.inboxID)
    }

    func pushTopics(forConversationIds conversationIds: [String]) async throws -> [String] {
        let client = try await clientManager.currentClient()
        var topics: [String] = []
        for conversationId in conversationIds {
            guard let conversation = try await client.conversations.findConversation(conversationId: conversationId) else {
                continue
            }
            topics.append(contentsOf: try await conversation.getPushTopics())
        }
        return topics
    }

    func fetchGroupInfo(conversationId: String) async throws -> GroupInfoData {
        let client = try await clientManager.currentClient()
        guard let conversation = try await client.conversations.findConversation(conversationId: conversationId) else {
            throw ConversationManagerError.conversationNotFound
        }
        guard case .group(let group) = conversation else {
            throw ConversationManagerError.notAGroup
        }
        return GroupInfoData(
            name: (try? group.name()) ?? "群聊",
            announcement: (try? group.description()) ?? ""
        )
    }

    func updateGroupName(conversationId: String, name: String) async throws {
        let client = try await clientManager.currentClient()
        guard let conversation = try await client.conversations.findConversation(conversationId: conversationId) else {
            throw ConversationManagerError.conversationNotFound
        }
        guard case .group(let group) = conversation else {
            throw ConversationManagerError.notAGroup
        }
        try await group.updateName(name: name)
    }

    func updateGroupAnnouncement(conversationId: String, announcement: String) async throws {
        let client = try await clientManager.currentClient()
        guard let conversation = try await client.conversations.findConversation(conversationId: conversationId) else {
            throw ConversationManagerError.conversationNotFound
        }
        guard case .group(let group) = conversation else {
            throw ConversationManagerError.notAGroup
        }
        try await group.updateDescription(description: announcement)
    }

    func fetchGroupMembers(conversationId: String) async throws -> [GroupMemberInfo] {
        let client = try await clientManager.currentClient()
        guard let conversation = try await client.conversations.findConversation(conversationId: conversationId) else {
            throw ConversationManagerError.conversationNotFound
        }
        guard case .group(let group) = conversation else {
            throw ConversationManagerError.notAGroup
        }
        let members = try await group.members
        return members.map {
            GroupMemberInfo(inboxId: $0.inboxId, isMe: $0.inboxId == client.inboxID)
        }
    }

    func updateMyNickname(conversationId: String, nickname: String) async throws -> NicknameUpdateInfo {
        let client = try await clientManager.currentClient()
        guard let conversation = try await client.conversations.findConversation(conversationId: conversationId) else {
            throw ConversationManagerError.conversationNotFound
        }
        guard case .group = conversation else {
            throw ConversationManagerError.notAGroup
        }
        _ = try await conversation.send(content: nickname, options: SendOptions(contentType: ContentTypeMemberNickname))
        return NicknameUpdateInfo(inboxId: client.inboxID, nickname: nickname)
    }

    private func map(_ message: DecodedMessage, conversationId: String, currentInboxId: String, isGroup: Bool) -> ChatMessageInfo? {
        let contentType = try? message.encodedContent.type
        if contentType == ContentTypeGroupUpdated {
            guard isGroup, let update: GroupUpdated = try? message.content() else {
                return nil
            }
            return ChatMessageInfo(
                id: message.id,
                text: Self.summarize(update),
                isFromMe: message.senderInboxId == currentInboxId,
                isSystemNotice: true,
                senderInboxId: message.senderInboxId,
                nicknameUpdate: nil,
                imageData: nil,
                audioData: nil,
                audioDuration: nil,
                sentAt: message.sentAt, sentAtNs: message.sentAtNs
            )
        }

        if contentType == ContentTypeMemberNickname {
            guard isGroup, let nickname: String = try? message.content(), !nickname.isEmpty else {
                return nil
            }
            let senderId = message.senderInboxId
            return ChatMessageInfo(
                id: message.id,
                text: "\(Self.actorPlaceholder) 设置了群昵称「\(nickname)」",
                isFromMe: senderId == currentInboxId,
                isSystemNotice: true,
                senderInboxId: senderId,
                nicknameUpdate: NicknameUpdateInfo(inboxId: senderId, nickname: nickname),
                imageData: nil,
                audioData: nil,
                audioDuration: nil,
                sentAt: message.sentAt, sentAtNs: message.sentAtNs
            )
        }

        if contentType == ContentTypeAttachment {
            guard let attachment: Attachment = try? message.content() else {
                return ChatMessageInfo(
                    id: message.id,
                    text: (try? message.body) ?? "",
                    isFromMe: message.senderInboxId == currentInboxId,
                    isSystemNotice: false,
                    senderInboxId: message.senderInboxId,
                    nicknameUpdate: nil,
                    imageData: nil,
                    audioData: nil,
                    audioDuration: nil,
                    sentAt: message.sentAt, sentAtNs: message.sentAtNs
                )
            }
            if attachment.mimeType.hasPrefix("audio/") {
                let duration = (try? AVAudioPlayer(data: attachment.data))?.duration
                return ChatMessageInfo(
                    id: message.id,
                    text: "",
                    isFromMe: message.senderInboxId == currentInboxId,
                    isSystemNotice: false,
                    senderInboxId: message.senderInboxId,
                    nicknameUpdate: nil,
                    imageData: nil,
                    audioData: attachment.data,
                    audioDuration: duration,
                    sentAt: message.sentAt, sentAtNs: message.sentAtNs
                )
            }
            guard attachment.mimeType.hasPrefix("image/") else {
                return ChatMessageInfo(
                    id: message.id,
                    text: (try? message.body) ?? "",
                    isFromMe: message.senderInboxId == currentInboxId,
                    isSystemNotice: false,
                    senderInboxId: message.senderInboxId,
                    nicknameUpdate: nil,
                    imageData: nil,
                    audioData: nil,
                    audioDuration: nil,
                    sentAt: message.sentAt, sentAtNs: message.sentAtNs
                )
            }
            return ChatMessageInfo(
                id: message.id,
                text: "",
                isFromMe: message.senderInboxId == currentInboxId,
                isSystemNotice: false,
                senderInboxId: message.senderInboxId,
                nicknameUpdate: nil,
                imageData: attachment.data,
                audioData: nil,
                audioDuration: nil,
                sentAt: message.sentAt, sentAtNs: message.sentAtNs
            )
        }

        return ChatMessageInfo(
            id: message.id,
            text: (try? message.body) ?? "",
            isFromMe: message.senderInboxId == currentInboxId,
            isSystemNotice: false,
            senderInboxId: message.senderInboxId,
            nicknameUpdate: nil,
            imageData: nil,
            audioData: nil,
            audioDuration: nil,
            sentAt: message.sentAt, sentAtNs: message.sentAtNs
        )
    }

    private static func isGroup(_ conversation: Conversation) -> Bool {
        if case .group = conversation { return true }
        return false
    }

    // The system notice text below is rendered before any local nickname/note state is
    // known (this is the Infrastructure layer); the View substitutes this placeholder with
    // the actor's resolved display name (nickname → note → abbreviated id) at render time.
    private static let actorPlaceholder = "{{actor}}"

    private static func summarize(_ update: GroupUpdated) -> String {
        let actor = actorPlaceholder
        var parts: [String] = []

        for change in update.metadataFieldChanges {
            let field = change.fieldName.lowercased()
            if field.contains("desc") {
                parts.append("\(actor) 更新了群公告")
            } else if field.contains("name") {
                parts.append("\(actor) 修改群名为「\(change.newValue)」")
            }
        }
        if !update.addedInboxes.isEmpty {
            parts.append("\(actor) 邀请了 \(update.addedInboxes.count) 位成员加入群聊")
        }
        if !update.removedInboxes.isEmpty {
            parts.append("\(actor) 移除了 \(update.removedInboxes.count) 位成员")
        }
        if !update.leftInboxes.isEmpty {
            parts.append("\(actor) 退出了群聊")
        }

        return parts.isEmpty ? "\(actor) 更新了群信息" : parts.joined(separator: "，")
    }

    private func summary(for conversation: Conversation, currentInboxId: String) async throws -> ConversationSummaryInfo {
        let lastMessage = try? await conversation.lastMessage()
        let contentType = try? lastMessage?.encodedContent.type
        let preview: String?
        if let lastMessage, contentType == ContentTypeAttachment,
           let attachment: Attachment = try? lastMessage.content() {
            preview = attachment.mimeType.hasPrefix("audio/") ? "[语音]" : "[图片]"
        } else if let lastMessage, contentType == ContentTypeGroupUpdated,
                  let update: GroupUpdated = try? lastMessage.content() {
            preview = Self.summarize(update)
        } else {
            preview = try? lastMessage?.body
        }
        let date = Date(timeIntervalSince1970: Double(conversation.lastActivityAtNs) / 1_000_000_000)
        let senderInboxId = lastMessage?.senderInboxId
        let isFromMe = senderInboxId == currentInboxId

        switch conversation {
        case .group(let group):
            return ConversationSummaryInfo(
                id: conversation.id,
                kind: .group,
                title: (try? group.name()) ?? "群聊",
                lastMessagePreview: preview,
                lastActivityDate: date,
                peerInboxId: nil,
                lastMessageSenderInboxId: senderInboxId,
                lastMessageIsFromMe: isFromMe
            )
        case .dm(let dm):
            let peer = (try? dm.peerInboxId) ?? "未知用户"
            return ConversationSummaryInfo(
                id: conversation.id,
                kind: .dm,
                title: Self.abbreviated(peer),
                lastMessagePreview: preview,
                lastActivityDate: date,
                peerInboxId: peer,
                lastMessageSenderInboxId: senderInboxId,
                lastMessageIsFromMe: isFromMe
            )
        }
    }

    private static func abbreviated(_ identifier: String) -> String {
        guard identifier.count > 10 else { return identifier }
        return "\(identifier.prefix(6))…\(identifier.suffix(4))"
    }
}
