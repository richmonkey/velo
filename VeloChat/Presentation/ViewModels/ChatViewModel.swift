import Foundation

enum ChatViewState {
    case loading
    case loaded([ChatMessage])
    case error(String)
}

@MainActor
final class ChatViewModel: ObservableObject {
    @Published private(set) var viewState: ChatViewState = .loading
    @Published private(set) var isSending = false

    let conversationTitle: String

    private let conversationId: String
    private let fetchMessages: FetchMessagesUseCase
    private let sendMessage: SendMessageUseCase
    private let streamMessages: StreamMessagesUseCase
    private var streamTask: Task<Void, Never>?

    init(
        conversationId: String,
        conversationTitle: String,
        fetchMessages: FetchMessagesUseCase,
        sendMessage: SendMessageUseCase,
        streamMessages: StreamMessagesUseCase
    ) {
        self.conversationId = conversationId
        self.conversationTitle = conversationTitle
        self.fetchMessages = fetchMessages
        self.sendMessage = sendMessage
        self.streamMessages = streamMessages
    }

    func didLoad() {
        Task { await load() }
        startStreaming()
    }

    func send(text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        isSending = true
        Task {
            defer { isSending = false }
            do {
                let message = try await sendMessage.execute(conversationId: conversationId, text: trimmed)
                appendIfNeeded(message)
            } catch {
                viewState = .error(error.localizedDescription)
            }
        }
    }

    func stopStreaming() {
        streamTask?.cancel()
        streamTask = nil
    }

    private func load() async {
        do {
            let messages = try await fetchMessages.execute(conversationId: conversationId)
            viewState = .loaded(messages)
        } catch {
            viewState = .error(error.localizedDescription)
        }
    }

    private func startStreaming() {
        streamTask = Task {
            do {
                for try await message in streamMessages.execute(conversationId: conversationId) {
                    appendIfNeeded(message)
                }
            } catch {
                // Live updates are best-effort; the initial load already surfaced any hard failure.
            }
        }
    }

    private func appendIfNeeded(_ message: ChatMessage) {
        guard case .loaded(var messages) = viewState else {
            viewState = .loaded([message])
            return
        }
        guard !messages.contains(where: { $0.id == message.id }) else { return }
        messages.append(message)
        viewState = .loaded(messages)
    }
}
