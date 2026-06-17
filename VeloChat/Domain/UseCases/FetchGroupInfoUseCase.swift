protocol FetchGroupInfoUseCase {
    func execute(conversationId: String) async throws -> GroupInfo
}

final class DefaultFetchGroupInfoUseCase: FetchGroupInfoUseCase {
    private let repository: ConversationRepositoryProtocol

    init(repository: ConversationRepositoryProtocol) {
        self.repository = repository
    }

    func execute(conversationId: String) async throws -> GroupInfo {
        try await repository.fetchGroupInfo(conversationId: conversationId)
    }
}
