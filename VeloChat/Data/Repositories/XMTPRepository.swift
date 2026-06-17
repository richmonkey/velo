final class XMTPRepository: XMTPRepositoryProtocol {
    private let clientManager: XMTPClientManaging

    init(clientManager: XMTPClientManaging) {
        self.clientManager = clientManager
    }

    func initializeClient() async throws -> XMTPIdentity {
        let info = try await clientManager.initializeClient()
        return XMTPIdentity(inboxId: info.inboxId, walletAddress: info.walletAddress)
    }
}
