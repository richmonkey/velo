protocol UpdateGroupNameUseCase {
    func execute(conversationId: String, name: String) async throws
}

final class DefaultUpdateGroupNameUseCase: UpdateGroupNameUseCase {
    private let repository: ConversationRepositoryProtocol

    init(repository: ConversationRepositoryProtocol) {
        self.repository = repository
    }

    func execute(conversationId: String, name: String) async throws {
        try await repository.updateGroupName(conversationId: conversationId, name: name)
    }
}
