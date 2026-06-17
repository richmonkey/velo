protocol StreamAllMessagesUseCase {
    func execute() -> AsyncThrowingStream<ChatMessage, Error>
}

final class DefaultStreamAllMessagesUseCase: StreamAllMessagesUseCase {
    private let repository: ChatRepositoryProtocol

    init(repository: ChatRepositoryProtocol) {
        self.repository = repository
    }

    func execute() -> AsyncThrowingStream<ChatMessage, Error> {
        repository.streamAllMessages()
    }
}
