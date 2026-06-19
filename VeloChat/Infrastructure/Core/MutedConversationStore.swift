import GRDB

final class MutedConversationStore: MutedConversationStoring {
    private let dbQueue: DatabaseQueue

    init(dbQueue: DatabaseQueue) {
        self.dbQueue = dbQueue
    }

    func isMuted(conversationId: String) -> Bool {
        (try? dbQueue.read { db in
            try Bool.fetchOne(db, sql: "SELECT is_muted FROM conversation_local_state WHERE conversation_id = ?", arguments: [conversationId])
        }) ?? false ?? false
    }

    func mute(conversationId: String) {
        setMuted(true, conversationId: conversationId)
    }

    func unmute(conversationId: String) {
        setMuted(false, conversationId: conversationId)
    }

    private func setMuted(_ muted: Bool, conversationId: String) {
        try? dbQueue.write { db in
            try db.execute(sql: """
                INSERT INTO conversation_local_state (conversation_id, is_muted) VALUES (?, ?)
                ON CONFLICT(conversation_id) DO UPDATE SET is_muted = excluded.is_muted
                """, arguments: [conversationId, muted])
        }
    }
}
