protocol FetchConversationsUseCase {
    func execute() async throws -> [ConversationSummary]
}

final class DefaultFetchConversationsUseCase: FetchConversationsUseCase {
    private let repository: ConversationRepositoryProtocol

    init(repository: ConversationRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [ConversationSummary] {
        try await repository.fetchConversations()
    }
}
