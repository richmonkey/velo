final class PushNotificationRepository: PushNotificationRepositoryProtocol {
    private let pushManager: PushNotificationManaging
    private let conversationManager: XMTPConversationManaging
    private let mutedConversationStore: MutedConversationStoring

    init(pushManager: PushNotificationManaging, conversationManager: XMTPConversationManaging, mutedConversationStore: MutedConversationStoring) {
        self.pushManager = pushManager
        self.conversationManager = conversationManager
        self.mutedConversationStore = mutedConversationStore
    }

    func requestPermissionAndRegister() async throws -> Bool {
        try await pushManager.requestPermissionAndRegister()
    }

    func syncSubscriptions(conversationIds: [String]) async throws {
        let subscribableIds = conversationIds.filter { !mutedConversationStore.isMuted(conversationId: $0) }
        guard !subscribableIds.isEmpty else { return }
        let topics = try await conversationManager.pushTopics(forConversationIds: subscribableIds)
        guard !topics.isEmpty else { return }
        try await pushManager.subscribe(topics: topics)
    }

    func setMuted(_ muted: Bool, conversationId: String) async throws {
        if muted {
            mutedConversationStore.mute(conversationId: conversationId)
        } else {
            mutedConversationStore.unmute(conversationId: conversationId)
        }
        let topics = try await conversationManager.pushTopics(forConversationIds: [conversationId])
        guard !topics.isEmpty else { return }
        if muted {
            try await pushManager.unsubscribe(topics: topics)
        } else {
            try await pushManager.subscribe(topics: topics)
        }
    }
}
