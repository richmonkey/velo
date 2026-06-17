import Foundation

enum ScanViewState: Equatable {
    case idle
    case submitting
    case success(ConversationSummary)
    case error(String)
}

@MainActor
final class ScanViewModel: ObservableObject {
    @Published private(set) var viewState: ScanViewState = .idle

    private let startConversation: StartConversationUseCase

    init(startConversation: StartConversationUseCase) {
        self.startConversation = startConversation
    }

    func submit(peerInboxId: String) {
        let trimmed = peerInboxId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        viewState = .submitting
        Task {
            do {
                let conversation = try await startConversation.execute(peerInboxId: trimmed)
                viewState = .success(conversation)
            } catch {
                viewState = .error(error.localizedDescription)
            }
        }
    }
}
