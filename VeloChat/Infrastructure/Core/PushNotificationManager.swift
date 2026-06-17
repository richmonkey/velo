import UIKit
import XMTPiOS

protocol PushNotificationManaging {
    func configure(pushServerHost: String)
    func requestPermissionAndRegister() async throws -> Bool
    func registerDeviceToken(_ token: Data) async throws
    func subscribe(topics: [String]) async throws
}

/// Thin wrapper around XMTPiOS's bundled `XMTPPush` helper, which already speaks
/// the `notifications.v1.Notifications` service described in http-api.md.
final class PushNotificationManager: PushNotificationManaging {
    func configure(pushServerHost: String) {
        XMTPPush.shared.setPushServer(pushServerHost)
    }

    func requestPermissionAndRegister() async throws -> Bool {
        let granted = try await XMTPPush.shared.request()
        if granted {
            await MainActor.run {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        return granted
    }

    func registerDeviceToken(_ token: Data) async throws {
        let hexToken = token.map { String(format: "%02x", $0) }.joined()
        try await XMTPPush.shared.register(token: hexToken)
    }

    func subscribe(topics: [String]) async throws {
        try await XMTPPush.shared.subscribe(topics: topics)
    }
}
