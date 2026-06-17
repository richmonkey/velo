protocol SetupPushNotificationsUseCase {
    func execute() async throws -> Bool
}

final class DefaultSetupPushNotificationsUseCase: SetupPushNotificationsUseCase {
    private let repository: PushNotificationRepositoryProtocol

    init(repository: PushNotificationRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> Bool {
        try await repository.requestPermissionAndRegister()
    }
}
