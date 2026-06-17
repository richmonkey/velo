protocol PushNotificationRepositoryProtocol {
    func requestPermissionAndRegister() async throws -> Bool
    func syncSubscriptions(conversationIds: [String]) async throws
}
