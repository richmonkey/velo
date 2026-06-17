import Foundation
import XMTPiOS

struct XMTPSessionInfo {
    let inboxId: String
    let walletAddress: String
}

protocol XMTPClientManaging {
    func initializeClient() async throws -> XMTPSessionInfo
    func currentClient() async throws -> Client
}

/// Creates the XMTP client using a key pair generated and stored on-device,
/// never delegating signing to an external wallet app.
final class XMTPClientManager: XMTPClientManaging {
    private enum KeychainKey {
        static let privateKey = "xmtp.local.privateKey"
        static let dbEncryptionKey = "xmtp.local.dbEncryptionKey"
    }

    private struct ClientBundle {
        let client: Client
        let walletAddress: String
    }

    private let keychain: KeychainService
    private var clientTask: Task<ClientBundle, Error>?

    init(keychain: KeychainService) {
        self.keychain = keychain
    }

    func initializeClient() async throws -> XMTPSessionInfo {
        let bundle = try await resolveClient()
        return XMTPSessionInfo(
            inboxId: bundle.client.inboxID,
            walletAddress: bundle.walletAddress
        )
    }

    func currentClient() async throws -> Client {
        try await resolveClient().client
    }

    /// Memoized so Loading and Home reuse the exact same client/session
    /// instead of triggering a second `Client.create`.
    private func resolveClient() async throws -> ClientBundle {
        if let clientTask {
            return try await clientTask.value
        }

        let task = Task { try await Self.createClientBundle(keychain: keychain) }
        clientTask = task
        return try await task.value
    }

    private static func createClientBundle(keychain: KeychainService) async throws -> ClientBundle {
        let account = try loadOrCreatePrivateKey(keychain: keychain)
        let dbEncryptionKey = try loadOrCreateDbEncryptionKey(keychain: keychain)

        let client = try await Client.create(
            account: account,
            options: ClientOptions(
                api: .init(env: .production, isSecure: true),
                dbEncryptionKey: dbEncryptionKey
            )
        )
        Client.register(codec: GroupUpdatedCodec())
        Client.register(codec: MemberNicknameCodec())
        Client.register(codec: AttachmentCodec())

        return ClientBundle(client: client, walletAddress: account.identity.identifier)
    }

    private static func loadOrCreatePrivateKey(keychain: KeychainService) throws -> PrivateKey {
        if let data = keychain.loadData(forKey: KeychainKey.privateKey),
           let jsonString = String(data: data, encoding: .utf8),
           let existing = try? PrivateKey(jsonString: jsonString) {
            return existing
        }

        let generated = try PrivateKey.generate()
        if let jsonString = try? generated.jsonString(),
           let data = jsonString.data(using: .utf8) {
            try keychain.saveData(data, forKey: KeychainKey.privateKey)
        }
        return generated
    }

    private static func loadOrCreateDbEncryptionKey(keychain: KeychainService) throws -> Data {
        if let existing = keychain.loadData(forKey: KeychainKey.dbEncryptionKey), existing.count == 32 {
            return existing
        }

        let generated = Data((0 ..< 32).map { _ in UInt8.random(in: .min ... .max) })
        try keychain.saveData(generated, forKey: KeychainKey.dbEncryptionKey)
        return generated
    }
}
