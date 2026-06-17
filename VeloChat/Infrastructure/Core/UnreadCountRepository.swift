import Foundation

final class UnreadCountRepository: UnreadCountRepositoryProtocol {
    private let defaults = UserDefaults.standard
    private let storageKey = "velo.unread_counts"

    func increment(conversationId: String) {
        var counts = loadAll()
        counts[conversationId, default: 0] += 1
        defaults.set(counts, forKey: storageKey)
    }

    func reset(conversationId: String) {
        var counts = loadAll()
        counts.removeValue(forKey: conversationId)
        defaults.set(counts, forKey: storageKey)
    }

    func loadAll() -> [String: Int] {
        defaults.dictionary(forKey: storageKey) as? [String: Int] ?? [:]
    }
}
