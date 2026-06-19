protocol HiddenConversationStoring {
    func isHidden(conversationId: String) -> Bool
    func hide(conversationId: String)
    func unhide(conversationId: String)
}
