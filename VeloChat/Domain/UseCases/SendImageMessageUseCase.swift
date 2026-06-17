import Foundation

protocol SendImageMessageUseCase {
    func execute(conversationId: String, imageData: Data, filename: String, mimeType: String) async throws -> ChatMessage
}

final class DefaultSendImageMessageUseCase: SendImageMessageUseCase {
    private let repository: ChatRepositoryProtocol

    init(repository: ChatRepositoryProtocol) {
        self.repository = repository
    }

    func execute(conversationId: String, imageData: Data, filename: String, mimeType: String) async throws -> ChatMessage {
        try await repository.sendImage(conversationId: conversationId, imageData: imageData, filename: filename, mimeType: mimeType)
    }
}
