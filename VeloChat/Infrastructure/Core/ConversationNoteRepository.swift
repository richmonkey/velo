import GRDB

final class ConversationNoteRepository: ConversationNoteRepositoryProtocol {
    private let dbQueue: DatabaseQueue

    init(dbQueue: DatabaseQueue) {
        self.dbQueue = dbQueue
    }

    func setNote(_ note: String, forConversationId id: String) {
        try? dbQueue.write { db in
            try db.execute(sql: """
                INSERT INTO conversation_local_state (conversation_id, note) VALUES (?, ?)
                ON CONFLICT(conversation_id) DO UPDATE SET note = excluded.note
                """, arguments: [id, note])
        }
    }

    func note(forConversationId id: String) -> String? {
        (try? dbQueue.read { db in
            try String.fetchOne(db, sql: "SELECT note FROM conversation_local_state WHERE conversation_id = ?", arguments: [id])
        }) ?? nil
    }

    func removeNote(forConversationId id: String) {
        try? dbQueue.write { db in
            try db.execute(sql: "UPDATE conversation_local_state SET note = NULL WHERE conversation_id = ?", arguments: [id])
        }
    }

    func loadAll() -> [String: String] {
        let rows = (try? dbQueue.read { db in
            try Row.fetchAll(db, sql: "SELECT conversation_id, note FROM conversation_local_state WHERE note IS NOT NULL")
        }) ?? []
        return rows.reduce(into: [:]) { result, row in
            result[row["conversation_id"]] = row["note"]
        }
    }

    func setNote(_ note: String, forInboxId inboxId: String) {
        try? dbQueue.write { db in
            try db.execute(sql: """
                INSERT INTO inbox_notes (inbox_id, note) VALUES (?, ?)
                ON CONFLICT(inbox_id) DO UPDATE SET note = excluded.note
                """, arguments: [inboxId, note])
        }
    }

    func note(forInboxId inboxId: String) -> String? {
        (try? dbQueue.read { db in
            try String.fetchOne(db, sql: "SELECT note FROM inbox_notes WHERE inbox_id = ?", arguments: [inboxId])
        }) ?? nil
    }

    func removeNote(forInboxId inboxId: String) {
        try? dbQueue.write { db in
            try db.execute(sql: "DELETE FROM inbox_notes WHERE inbox_id = ?", arguments: [inboxId])
        }
    }

    func loadAllInboxNotes() -> [String: String] {
        let rows = (try? dbQueue.read { db in
            try Row.fetchAll(db, sql: "SELECT inbox_id, note FROM inbox_notes")
        }) ?? []
        return rows.reduce(into: [:]) { result, row in
            result[row["inbox_id"]] = row["note"]
        }
    }
}
