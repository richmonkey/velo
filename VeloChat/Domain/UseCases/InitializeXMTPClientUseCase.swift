protocol InitializeXMTPClientUseCase {
    func execute() async throws -> XMTPIdentity
}

final class DefaultInitializeXMTPClientUseCase: InitializeXMTPClientUseCase {
    private let repository: XMTPRepositoryProtocol

    init(repository: XMTPRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> XMTPIdentity {
        try await repository.initializeClient()
    }
}
