protocol FetchGroupMembersUseCase {
    func execute(conversationId: String) async throws -> [GroupMember]
}

final class DefaultFetchGroupMembersUseCase: FetchGroupMembersUseCase {
    private let repository: ConversationRepositoryProtocol

    init(repository: ConversationRepositoryProtocol) {
        self.repository = repository
    }

    func execute(conversationId: String) async throws -> [GroupMember] {
        try await repository.fetchGroupMembers(conversationId: conversationId)
    }
}
