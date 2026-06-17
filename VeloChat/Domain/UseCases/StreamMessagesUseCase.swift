protocol StreamMessagesUseCase {
    func execute(conversationId: String) -> AsyncThrowingStream<ChatMessage, Error>
}

final class DefaultStreamMessagesUseCase: StreamMessagesUseCase {
    private let repository: ChatRepositoryProtocol

    init(repository: ChatRepositoryProtocol) {
        self.repository = repository
    }

    func execute(conversationId: String) -> AsyncThrowingStream<ChatMessage, Error> {
        repository.streamMessages(conversationId: conversationId)
    }
}
