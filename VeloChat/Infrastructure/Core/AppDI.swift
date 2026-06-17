final class AppDI {
    static let shared = AppDI()

    private static let pushServerHost = "http://192.168.1.198:8080"

    let initializeXMTPClientUseCase: InitializeXMTPClientUseCase
    let fetchConversationsUseCase: FetchConversationsUseCase
    let startConversationUseCase: StartConversationUseCase
    let fetchMessagesUseCase: FetchMessagesUseCase
    let sendMessageUseCase: SendMessageUseCase
    let streamMessagesUseCase: StreamMessagesUseCase
    let pushNotificationManager: PushNotificationManaging
    let setupPushNotificationsUseCase: SetupPushNotificationsUseCase
    let syncPushSubscriptionsUseCase: SyncPushSubscriptionsUseCase

    private init() {
        let keychain = KeychainService()
        let clientManager = XMTPClientManager(keychain: keychain)

        let repository = XMTPRepository(clientManager: clientManager)
        initializeXMTPClientUseCase = DefaultInitializeXMTPClientUseCase(repository: repository)

        let conversationManager = XMTPConversationManager(clientManager: clientManager)
        let conversationRepository = ConversationRepository(conversationManager: conversationManager)
        fetchConversationsUseCase = DefaultFetchConversationsUseCase(repository: conversationRepository)
        startConversationUseCase = DefaultStartConversationUseCase(repository: conversationRepository)

        let chatRepository = ChatRepository(conversationManager: conversationManager)
        fetchMessagesUseCase = DefaultFetchMessagesUseCase(repository: chatRepository)
        sendMessageUseCase = DefaultSendMessageUseCase(repository: chatRepository)
        streamMessagesUseCase = DefaultStreamMessagesUseCase(repository: chatRepository)

        let pushManager = PushNotificationManager()
        pushManager.configure(pushServerHost: Self.pushServerHost)
        pushNotificationManager = pushManager
        let pushRepository = PushNotificationRepository(pushManager: pushManager, conversationManager: conversationManager)
        setupPushNotificationsUseCase = DefaultSetupPushNotificationsUseCase(repository: pushRepository)
        syncPushSubscriptionsUseCase = DefaultSyncPushSubscriptionsUseCase(repository: pushRepository)
    }

    @MainActor
    func makeLoadingViewModel() -> LoadingViewModel {
        LoadingViewModel(initializeXMTPClient: initializeXMTPClientUseCase)
    }

    @MainActor
    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            fetchConversations: fetchConversationsUseCase,
            setupPushNotifications: setupPushNotificationsUseCase,
            syncPushSubscriptions: syncPushSubscriptionsUseCase
        )
    }

    @MainActor
    func makeMeViewModel() -> MeViewModel {
        MeViewModel(initializeXMTPClient: initializeXMTPClientUseCase)
    }

    @MainActor
    func makeScanViewModel() -> ScanViewModel {
        ScanViewModel(startConversation: startConversationUseCase)
    }

    @MainActor
    func makeChatViewModel(conversationId: String, conversationTitle: String) -> ChatViewModel {
        ChatViewModel(
            conversationId: conversationId,
            conversationTitle: conversationTitle,
            fetchMessages: fetchMessagesUseCase,
            sendMessage: sendMessageUseCase,
            streamMessages: streamMessagesUseCase
        )
    }
}
