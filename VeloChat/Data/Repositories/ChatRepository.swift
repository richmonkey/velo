import Foundation

final class ChatRepository: ChatRepositoryProtocol {
    private let conversationManager: XMTPConversationManaging

    init(conversationManager: XMTPConversationManaging) {
        self.conversationManager = conversationManager
    }

    func fetchMessages(conversationId: String) async throws -> [ChatMessage] {
        try await conversationManager.fetchMessages(conversationId: conversationId).map(Self.map)
    }

    func sendMessage(conversationId: String, text: String) async throws -> ChatMessage {
        Self.map(try await conversationManager.sendMessage(conversationId: conversationId, text: text))
    }

    func sendImage(conversationId: String, imageData: Data, filename: String, mimeType: String) async throws -> ChatMessage {
        Self.map(try await conversationManager.sendImage(conversationId: conversationId, imageData: imageData, filename: filename, mimeType: mimeType))
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

    func streamAllMessages() -> AsyncThrowingStream<String, Error> {
        conversationManager.streamAllMessages()
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
            sentAt: info.sentAt
        )
    }
}
