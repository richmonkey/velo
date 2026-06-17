protocol XMTPRepositoryProtocol {
    func initializeClient() async throws -> XMTPIdentity
}
