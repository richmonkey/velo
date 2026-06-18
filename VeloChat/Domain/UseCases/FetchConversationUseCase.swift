protocol FetchConversationUseCase {
    func execute(conversationId: String) async throws -> ConversationSummary?
}

final class DefaultFetchConversationUseCase: FetchConversationUseCase {
    private let repository: ConversationRepositoryProtocol

    init(repository: ConversationRepositoryProtocol) {
        self.repository = repository
    }

    func execute(conversationId: String) async throws -> ConversationSummary? {
        try await repository.fetchConversation(conversationId: conversationId)
    }
}
