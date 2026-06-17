protocol StreamAllMessagesUseCase {
    func execute() -> AsyncThrowingStream<String, Error>
}

final class DefaultStreamAllMessagesUseCase: StreamAllMessagesUseCase {
    private let repository: ChatRepositoryProtocol

    init(repository: ChatRepositoryProtocol) {
        self.repository = repository
    }

    func execute() -> AsyncThrowingStream<String, Error> {
        repository.streamAllMessages()
    }
}
