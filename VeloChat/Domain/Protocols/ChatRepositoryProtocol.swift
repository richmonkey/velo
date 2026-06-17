import Foundation

protocol ChatRepositoryProtocol {
    func fetchMessages(conversationId: String) async throws -> [ChatMessage]
    func sendMessage(conversationId: String, text: String) async throws -> ChatMessage
    func sendImage(conversationId: String, imageData: Data, filename: String, mimeType: String) async throws -> ChatMessage
    func streamMessages(conversationId: String) -> AsyncThrowingStream<ChatMessage, Error>
    func streamAllMessages() -> AsyncThrowingStream<String, Error>
}
