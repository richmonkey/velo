protocol CreateGroupUseCase {
    func execute(name: String, peerInboxIds: [String]) async throws -> ConversationSummary
}

final class DefaultCreateGroupUseCase: CreateGroupUseCase {
    private let repository: ConversationRepositoryProtocol

    init(repository: ConversationRepositoryProtocol) {
        self.repository = repository
    }

    func execute(name: String, peerInboxIds: [String]) async throws -> ConversationSummary {
        try await repository.createGroup(name: name, peerInboxIds: peerInboxIds)
    }
}
