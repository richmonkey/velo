protocol DeleteConversationUseCase {
    func execute(conversationId: String) async throws
}

final class DefaultDeleteConversationUseCase: DeleteConversationUseCase {
    private let repository: ConversationRepositoryProtocol

    init(repository: ConversationRepositoryProtocol) {
        self.repository = repository
    }

    func execute(conversationId: String) async throws {
        try await repository.deleteConversation(conversationId: conversationId)
    }
}
