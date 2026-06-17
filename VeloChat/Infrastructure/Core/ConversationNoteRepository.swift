import Foundation

final class ConversationNoteRepository: ConversationNoteRepositoryProtocol {
    private let defaults = UserDefaults.standard
    private let storageKey = "velo.conversation_notes"

    func setNote(_ note: String, forConversationId id: String) {
        var notes = loadAll()
        notes[id] = note
        defaults.set(notes, forKey: storageKey)
    }

    func note(forConversationId id: String) -> String? {
        loadAll()[id]
    }

    func removeNote(forConversationId id: String) {
        var notes = loadAll()
        notes.removeValue(forKey: id)
        defaults.set(notes, forKey: storageKey)
    }

    func loadAll() -> [String: String] {
        defaults.dictionary(forKey: storageKey) as? [String: String] ?? [:]
    }
}
