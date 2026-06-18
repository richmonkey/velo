import Foundation

final class ChatRepository: ChatRepositoryProtocol {
    private let conversationManager: XMTPConversationManaging

    init(conversationManager: XMTPConversationManaging) {
        self.conversationManager = conversationManager
    }

    func fetchMessages(conversationId: String, beforeNs: Int64?) async throws -> [ChatMessage] {
        try await conversationManager.fetchMessages(conversationId: conversationId, beforeNs: beforeNs).map(Self.map)
    }

    func sendMessage(conversationId: String, text: String) async throws -> ChatMessage {
        Self.map(try await conversationManager.sendMessage(conversationId: conversationId, text: text))
    }

    func sendImage(conversationId: String, imageData: Data, filename: String, mimeType: String) async throws -> ChatMessage {
        Self.map(try await conversationManager.sendImage(conversationId: conversationId, imageData: imageData, filename: filename, mimeType: mimeType))
    }

    func sendVoiceMessage(conversationId: String, audioData: Data, filename: String, mimeType: String, duration: TimeInterval) async throws -> ChatMessage {
        Self.map(try await conversationManager.sendVoiceMessage(conversationId: conversationId, audioData: audioData, filename: filename, mimeType: mimeType, duration: duration))
    }

    func streamMessages(conversationId: String) -> AsyncThrowingStream<ChatMessage, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    for try await info in conversationManager.streamMessages(conversationId: conversationId) {
                        continuation.yield(Self.map(info))
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    func streamAllMessages() -> AsyncThrowingStream<ConversationActivity, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    for try await event in conversationManager.streamAllMessages() {
                        continuation.yield(ConversationActivity(
                            conversationId: event.conversationId,
                            isFromMe: event.isFromMe,
                            nicknameUpdate: event.nicknameUpdate.map { ConversationActivity.NicknameUpdate(inboxId: $0.inboxId, nickname: $0.nickname) }
                        ))
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    private static func map(_ info: ChatMessageInfo) -> ChatMessage {
        ChatMessage(
            id: info.id,
            text: info.text,
            isFromMe: info.isFromMe,
            isSystemNotice: info.isSystemNotice,
            senderInboxId: info.senderInboxId,
            nicknameUpdate: info.nicknameUpdate.map { ChatMessage.NicknameUpdate(inboxId: $0.inboxId, nickname: $0.nickname) },
            imageData: info.imageData,
            audioData: info.audioData,
            audioDuration: info.audioDuration,
            sentAt: info.sentAt,
            sentAtNs: info.sentAtNs
        )
    }
}
