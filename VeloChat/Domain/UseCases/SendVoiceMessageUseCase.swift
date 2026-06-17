import Foundation

protocol SendVoiceMessageUseCase {
    func execute(conversationId: String, audioData: Data, filename: String, mimeType: String, duration: TimeInterval) async throws -> ChatMessage
}

final class DefaultSendVoiceMessageUseCase: SendVoiceMessageUseCase {
    private let repository: ChatRepositoryProtocol

    init(repository: ChatRepositoryProtocol) {
        self.repository = repository
    }

    func execute(conversationId: String, audioData: Data, filename: String, mimeType: String, duration: TimeInterval) async throws -> ChatMessage {
        try await repository.sendVoiceMessage(conversationId: conversationId, audioData: audioData, filename: filename, mimeType: mimeType, duration: duration)
    }
}
