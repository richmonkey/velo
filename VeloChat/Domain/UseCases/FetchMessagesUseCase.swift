protocol FetchMessagesUseCase {
    func execute(conversationId: String) async throws -> [ChatMessage]
}

final class DefaultFetchMessagesUseCase: FetchMessagesUseCase {
    private let repository: ChatRepositoryProtocol

    init(repository: ChatRepositoryProtocol) {
        self.repository = repository
    }

    func execute(conversationId: String) async throws -> [ChatMessage] {
        try await repository.fetchMessages(conversationId: conversationId)
    }
}
