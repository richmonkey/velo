import Foundation
import GRDB

final class DatabaseManager {
    static let shared = DatabaseManager()
    let dbQueue: DatabaseQueue

    private init() {
        let directory = try! FileManager.default.url(
            for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true
        )
        dbQueue = try! DatabaseQueue(path: directory.appendingPathComponent("velo.sqlite3").path)
        try! migrator.migrate(dbQueue)
    }

    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        migrator.registerMigration("v1_conversationLocalState") { db in
            try db.create(table: "conversation_local_state") { t in
                t.column("conversation_id", .text).primaryKey()
                t.column("is_hidden", .boolean).notNull().defaults(to: false)
                t.column("is_muted", .boolean).notNull().defaults(to: false)
                t.column("unread_count", .integer).notNull().defaults(to: 0)
                t.column("note", .text)
            }
            try db.create(table: "inbox_notes") { t in
                t.column("inbox_id", .text).primaryKey()
                t.column("note", .text).notNull()
            }
        }
        return migrator
    }
}
