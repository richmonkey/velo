import Foundation
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
}

struct ChatMessageInfo {
    let id: String
    let text: String
    let isFromMe: Bool
    let sentAt: Date
}

enum ConversationManagerError: LocalizedError {
    case conversationNotFound

    var errorDescription: String? {
        "未找到该会话"
    }
}

protocol XMTPConversationManaging {
    func fetchConversations() async throws -> [ConversationSummaryInfo]
    func startConversation(peerInboxId: String) async throws -> ConversationSummaryInfo
    func fetchMessages(conversationId: String) async throws -> [ChatMessageInfo]
    func sendMessage(conversationId: String, text: String) async throws -> ChatMessageInfo
    func streamMessages(conversationId: String) -> AsyncThrowingStream<ChatMessageInfo, Error>
    func streamAllMessages() -> AsyncThrowingStream<String, Error>
    func createGroup(name: String, peerInboxIds: [String]) async throws -> ConversationSummaryInfo
    func pushTopics(forConversationIds conversationIds: [String]) async throws -> [String]
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
            summaries.append(try await summary(for: conversation))
        }
        return summaries
    }

    func startConversation(peerInboxId: String) async throws -> ConversationSummaryInfo {
        let client = try await clientManager.currentClient()
        let conversation = try await client.conversations.newConversation(with: peerInboxId)
        return try await summary(for: conversation)
    }

    func fetchMessages(conversationId: String) async throws -> [ChatMessageInfo] {
        let client = try await clientManager.currentClient()
        guard let conversation = try await client.conversations.findConversation(conversationId: conversationId) else {
            throw ConversationManagerError.conversationNotFound
        }
        try await conversation.sync()
        let messages = try await conversation.messages(limit: 50, direction: .ascending)
        return messages.map { map($0, currentInboxId: client.inboxID) }
    }

    func sendMessage(conversationId: String, text: String) async throws -> ChatMessageInfo {
        let client = try await clientManager.currentClient()
        guard let conversation = try await client.conversations.findConversation(conversationId: conversationId) else {
            throw ConversationManagerError.conversationNotFound
        }
        let messageId = try await conversation.send(text: text)
        return ChatMessageInfo(id: messageId, text: text, isFromMe: true, sentAt: Date())
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
                    for try await message in conversation.streamMessages() {
                        continuation.yield(self.map(message, currentInboxId: client.inboxID))
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    func streamAllMessages() -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    let client = try await self.clientManager.currentClient()
                    for try await message in await client.conversations.streamAllMessages() {
                        continuation.yield(message.topic)
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
        return try await summary(for: .group(group))
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

    private func map(_ message: DecodedMessage, currentInboxId: String) -> ChatMessageInfo {
        ChatMessageInfo(
            id: message.id,
            text: (try? message.body) ?? "",
            isFromMe: message.senderInboxId == currentInboxId,
            sentAt: message.sentAt
        )
    }

    private func summary(for conversation: Conversation) async throws -> ConversationSummaryInfo {
        let lastMessage = try? await conversation.lastMessage()
        let preview = try? lastMessage?.body
        let date = Date(timeIntervalSince1970: Double(conversation.lastActivityAtNs) / 1_000_000_000)

        switch conversation {
        case .group(let group):
            return ConversationSummaryInfo(
                id: conversation.id,
                kind: .group,
                title: (try? group.name()) ?? "群聊",
                lastMessagePreview: preview,
                lastActivityDate: date,
                peerInboxId: nil
            )
        case .dm(let dm):
            let peer = (try? dm.peerInboxId) ?? "未知用户"
            return ConversationSummaryInfo(
                id: conversation.id,
                kind: .dm,
                title: Self.abbreviated(peer),
                lastMessagePreview: preview,
                lastActivityDate: date,
                peerInboxId: peer
            )
        }
    }

    private static func abbreviated(_ identifier: String) -> String {
        guard identifier.count > 10 else { return identifier }
        return "\(identifier.prefix(6))…\(identifier.suffix(4))"
    }
}
