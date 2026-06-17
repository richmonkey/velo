protocol UpdateGroupAnnouncementUseCase {
    func execute(conversationId: String, announcement: String) async throws
}

final class DefaultUpdateGroupAnnouncementUseCase: UpdateGroupAnnouncementUseCase {
    private let repository: ConversationRepositoryProtocol

    init(repository: ConversationRepositoryProtocol) {
        self.repository = repository
    }

    func execute(conversationId: String, announcement: String) async throws {
        try await repository.updateGroupAnnouncement(conversationId: conversationId, announcement: announcement)
    }
}
