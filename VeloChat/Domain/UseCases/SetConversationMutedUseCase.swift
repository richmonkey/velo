protocol SetConversationMutedUseCase {
    func execute(conversationId: String, isMuted: Bool) async throws
}

final class DefaultSetConversationMutedUseCase: SetConversationMutedUseCase {
    private let repository: PushNotificationRepositoryProtocol

    init(repository: PushNotificationRepositoryProtocol) {
        self.repository = repository
    }

    func execute(conversationId: String, isMuted: Bool) async throws {
        try await repository.setMuted(isMuted, conversationId: conversationId)
    }
}
