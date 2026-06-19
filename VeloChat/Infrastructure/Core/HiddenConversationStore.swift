import GRDB

final class HiddenConversationStore: HiddenConversationStoring {
    private let dbQueue: DatabaseQueue

    init(dbQueue: DatabaseQueue) {
        self.dbQueue = dbQueue
    }

    func isHidden(conversationId: String) -> Bool {
        (try? dbQueue.read { db in
            try Bool.fetchOne(db, sql: "SELECT is_hidden FROM conversation_local_state WHERE conversation_id = ?", arguments: [conversationId])
        }) ?? false ?? false
    }

    func hide(conversationId: String) {
        setHidden(true, conversationId: conversationId)
    }

    func unhide(conversationId: String) {
        setHidden(false, conversationId: conversationId)
    }

    private func setHidden(_ hidden: Bool, conversationId: String) {
        try? dbQueue.write { db in
            try db.execute(sql: """
                INSERT INTO conversation_local_state (conversation_id, is_hidden) VALUES (?, ?)
                ON CONFLICT(conversation_id) DO UPDATE SET is_hidden = excluded.is_hidden
                """, arguments: [conversationId, hidden])
        }
    }
}
