protocol SyncPushSubscriptionsUseCase {
    func execute(conversationIds: [String]) async throws
}

final class DefaultSyncPushSubscriptionsUseCase: SyncPushSubscriptionsUseCase {
    private let repository: PushNotificationRepositoryProtocol

    init(repository: PushNotificationRepositoryProtocol) {
        self.repository = repository
    }

    func execute(conversationIds: [String]) async throws {
        try await repository.syncSubscriptions(conversationIds: conversationIds)
    }
}
