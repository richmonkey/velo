import Foundation

@MainActor
final class ConversationSettingsViewModel: ObservableObject {
    @Published var note: String

    private let conversationId: String
    private let peerInboxId: String?
    private let noteRepository: ConversationNoteRepositoryProtocol

    init(conversationId: String, peerInboxId: String?, noteRepository: ConversationNoteRepositoryProtocol) {
        self.conversationId = conversationId
        self.peerInboxId = peerInboxId
        self.noteRepository = noteRepository
        self.note = noteRepository.note(forConversationId: conversationId) ?? ""
    }

    func save() {
        let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            noteRepository.removeNote(forConversationId: conversationId)
            if let peerInboxId { noteRepository.removeNote(forInboxId: peerInboxId) }
        } else {
            noteRepository.setNote(trimmed, forConversationId: conversationId)
            if let peerInboxId { noteRepository.setNote(trimmed, forInboxId: peerInboxId) }
        }
    }
}
