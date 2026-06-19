protocol DissolveGroupUseCase {
    func execute(conversationId: String) async throws
}

final class DefaultDissolveGroupUseCase: DissolveGroupUseCase {
    private let repository: ConversationRepositoryProtocol

    init(repository: ConversationRepositoryProtocol) {
        self.repository = repository
    }

    func execute(conversationId: String) async throws {
        try await repository.dissolveGroup(conversationId: conversationId)
    }
}
