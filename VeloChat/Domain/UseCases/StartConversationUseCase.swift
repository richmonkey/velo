protocol StartConversationUseCase {
    func execute(peerInboxId: String) async throws -> ConversationSummary
}

final class DefaultStartConversationUseCase: StartConversationUseCase {
    private let repository: ConversationRepositoryProtocol

    init(repository: ConversationRepositoryProtocol) {
        self.repository = repository
    }

    func execute(peerInboxId: String) async throws -> ConversationSummary {
        try await repository.startConversation(peerInboxId: peerInboxId)
    }
}
