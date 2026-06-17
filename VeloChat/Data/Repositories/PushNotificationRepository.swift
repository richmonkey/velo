final class PushNotificationRepository: PushNotificationRepositoryProtocol {
    private let pushManager: PushNotificationManaging
    private let conversationManager: XMTPConversationManaging

    init(pushManager: PushNotificationManaging, conversationManager: XMTPConversationManaging) {
        self.pushManager = pushManager
        self.conversationManager = conversationManager
    }

    func requestPermissionAndRegister() async throws -> Bool {
        try await pushManager.requestPermissionAndRegister()
    }

    func syncSubscriptions(conversationIds: [String]) async throws {
        let topics = try await conversationManager.pushTopics(forConversationIds: conversationIds)
        guard !topics.isEmpty else { return }
        try await pushManager.subscribe(topics: topics)
    }
}
