protocol PushNotificationRepositoryProtocol {
    func requestPermissionAndRegister() async throws -> Bool
    func syncSubscriptions(conversationIds: [String]) async throws
    func setMuted(_ muted: Bool, conversationId: String) async throws
}
