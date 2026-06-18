import Foundation

final class ConversationNoteRepository: ConversationNoteRepositoryProtocol {
    private let defaults = UserDefaults.standard
    private let storageKey = "velo.conversation_notes"
    private let inboxStorageKey = "velo.inbox_notes"

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

    func setNote(_ note: String, forInboxId inboxId: String) {
        var notes = loadAllInboxNotes()
        notes[inboxId] = note
        defaults.set(notes, forKey: inboxStorageKey)
    }

    func note(forInboxId inboxId: String) -> String? {
        loadAllInboxNotes()[inboxId]
    }

    func removeNote(forInboxId inboxId: String) {
        var notes = loadAllInboxNotes()
        notes.removeValue(forKey: inboxId)
        defaults.set(notes, forKey: inboxStorageKey)
    }

    func loadAllInboxNotes() -> [String: String] {
        defaults.dictionary(forKey: inboxStorageKey) as? [String: String] ?? [:]
    }
}
