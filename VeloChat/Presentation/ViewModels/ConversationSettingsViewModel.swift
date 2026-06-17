import Foundation

@MainActor
final class ConversationSettingsViewModel: ObservableObject {
    @Published var note: String

    private let conversationId: String
    private let noteRepository: ConversationNoteRepositoryProtocol

    init(conversationId: String, noteRepository: ConversationNoteRepositoryProtocol) {
        self.conversationId = conversationId
        self.noteRepository = noteRepository
        self.note = noteRepository.note(forConversationId: conversationId) ?? ""
    }

    func save() {
        let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            noteRepository.removeNote(forConversationId: conversationId)
        } else {
            noteRepository.setNote(trimmed, forConversationId: conversationId)
        }
    }
}
