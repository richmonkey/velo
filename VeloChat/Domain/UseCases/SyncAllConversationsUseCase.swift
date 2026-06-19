protocol SyncAllConversationsUseCase {
    func execute() async throws
}

final class DefaultSyncAllConversationsUseCase: SyncAllConversationsUseCase {
    private let repository: ConversationRepositoryProtocol

    init(repository: ConversationRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws {
        try await repository.syncAllConversations()
    }
}
