protocol MutedConversationStoring {
    func isMuted(conversationId: String) -> Bool
    func mute(conversationId: String)
    func unmute(conversationId: String)
}
