protocol UpdateMyNicknameUseCase {
    func execute(conversationId: String, nickname: String) async throws
}

final class DefaultUpdateMyNicknameUseCase: UpdateMyNicknameUseCase {
    private let repository: ConversationRepositoryProtocol

    init(repository: ConversationRepositoryProtocol) {
        self.repository = repository
    }

    func execute(conversationId: String, nickname: String) async throws {
        try await repository.updateMyNickname(conversationId: conversationId, nickname: nickname)
    }
}
