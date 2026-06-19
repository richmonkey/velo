import GRDB

final class UnreadCountRepository: UnreadCountRepositoryProtocol {
    private let dbQueue: DatabaseQueue

    init(dbQueue: DatabaseQueue) {
        self.dbQueue = dbQueue
    }

    func increment(conversationId: String) {
        try? dbQueue.write { db in
            try db.execute(sql: """
                INSERT INTO conversation_local_state (conversation_id, unread_count) VALUES (?, 1)
                ON CONFLICT(conversation_id) DO UPDATE SET unread_count = unread_count + 1
                """, arguments: [conversationId])
        }
    }

    func reset(conversationId: String) {
        try? dbQueue.write { db in
            try db.execute(sql: "UPDATE conversation_local_state SET unread_count = 0 WHERE conversation_id = ?", arguments: [conversationId])
        }
    }

    func loadAll() -> [String: Int] {
        let rows = (try? dbQueue.read { db in
            try Row.fetchAll(db, sql: "SELECT conversation_id, unread_count FROM conversation_local_state WHERE unread_count > 0")
        }) ?? []
        return rows.reduce(into: [:]) { result, row in
            result[row["conversation_id"]] = row["unread_count"]
        }
    }
}
