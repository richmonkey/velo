final class AppDI {
    static let shared = AppDI()

    private static let pushServerHost = "http://192.168.1.198:8080"

    let initializeXMTPClientUseCase: InitializeXMTPClientUseCase
    let fetchConversationsUseCase: FetchConversationsUseCase
    let startConversationUseCase: StartConversationUseCase
    let fetchMessagesUseCase: FetchMessagesUseCase
    let sendMessageUseCase: SendMessageUseCase
    let streamMessagesUseCase: StreamMessagesUseCase
    let streamAllMessagesUseCase: StreamAllMessagesUseCase
    let createGroupUseCase: CreateGroupUseCase
    let fetchGroupInfoUseCase: FetchGroupInfoUseCase
    let updateGroupAnnouncementUseCase: UpdateGroupAnnouncementUseCase
    let fetchGroupMembersUseCase: FetchGroupMembersUseCase
    let updateMyNicknameUseCase: UpdateMyNicknameUseCase
    let pushNotificationManager: PushNotificationManaging
    let setupPushNotificationsUseCase: SetupPushNotificationsUseCase
    let syncPushSubscriptionsUseCase: SyncPushSubscriptionsUseCase
    let unreadCountRepository: UnreadCountRepositoryProtocol
    let conversationNoteRepository: ConversationNoteRepositoryProtocol
    let memberNicknameStore: MemberNicknameStoring

    private init() {
        let keychain = KeychainService()
        let clientManager = XMTPClientManager(keychain: keychain)

        let repository = XMTPRepository(clientManager: clientManager)
        initializeXMTPClientUseCase = DefaultInitializeXMTPClientUseCase(repository: repository)

        memberNicknameStore = MemberNicknameStore()
        let conversationManager = XMTPConversationManager(clientManager: clientManager, memberNicknameStore: memberNicknameStore)
        let conversationRepository = ConversationRepository(conversationManager: conversationManager)
        fetchConversationsUseCase = DefaultFetchConversationsUseCase(repository: conversationRepository)
        startConversationUseCase = DefaultStartConversationUseCase(repository: conversationRepository)

        let chatRepository = ChatRepository(conversationManager: conversationManager)
        fetchMessagesUseCase = DefaultFetchMessagesUseCase(repository: chatRepository)
        sendMessageUseCase = DefaultSendMessageUseCase(repository: chatRepository)
        streamMessagesUseCase = DefaultStreamMessagesUseCase(repository: chatRepository)
        streamAllMessagesUseCase = DefaultStreamAllMessagesUseCase(repository: chatRepository)
        createGroupUseCase = DefaultCreateGroupUseCase(repository: conversationRepository)
        fetchGroupInfoUseCase = DefaultFetchGroupInfoUseCase(repository: conversationRepository)
        updateGroupAnnouncementUseCase = DefaultUpdateGroupAnnouncementUseCase(repository: conversationRepository)
        fetchGroupMembersUseCase = DefaultFetchGroupMembersUseCase(repository: conversationRepository)
        updateMyNicknameUseCase = DefaultUpdateMyNicknameUseCase(repository: conversationRepository)

        let pushManager = PushNotificationManager()
        pushManager.configure(pushServerHost: Self.pushServerHost)
        pushNotificationManager = pushManager
        let pushRepository = PushNotificationRepository(pushManager: pushManager, conversationManager: conversationManager)
        setupPushNotificationsUseCase = DefaultSetupPushNotificationsUseCase(repository: pushRepository)
        syncPushSubscriptionsUseCase = DefaultSyncPushSubscriptionsUseCase(repository: pushRepository)

        unreadCountRepository = UnreadCountRepository()
        conversationNoteRepository = ConversationNoteRepository()
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
            syncPushSubscriptions: syncPushSubscriptionsUseCase,
            streamAllMessages: streamAllMessagesUseCase,
            unreadCountStore: unreadCountRepository,
            noteRepository: conversationNoteRepository
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
    func makeChatViewModel(conversationId: String, conversationTitle: String, kind: ConversationSummary.Kind) -> ChatViewModel {
        ChatViewModel(
            conversationId: conversationId,
            conversationTitle: conversationTitle,
            kind: kind,
            fetchMessages: fetchMessagesUseCase,
            sendMessage: sendMessageUseCase,
            streamMessages: streamMessagesUseCase,
            unreadCountStore: unreadCountRepository,
            noteRepository: conversationNoteRepository,
            fetchGroupMembers: fetchGroupMembersUseCase
        )
    }

    @MainActor
    func makeCreateGroupViewModel() -> CreateGroupViewModel {
        CreateGroupViewModel(
            fetchConversations: fetchConversationsUseCase,
            noteRepository: conversationNoteRepository,
            createGroup: createGroupUseCase
        )
    }

    @MainActor
    func makeConversationSettingsViewModel(conversationId: String) -> ConversationSettingsViewModel {
        ConversationSettingsViewModel(
            conversationId: conversationId,
            noteRepository: conversationNoteRepository
        )
    }

    @MainActor
    func makeGroupSettingsViewModel(conversationId: String) -> GroupSettingsViewModel {
        GroupSettingsViewModel(
            conversationId: conversationId,
            fetchGroupInfo: fetchGroupInfoUseCase,
            updateGroupAnnouncement: updateGroupAnnouncementUseCase,
            fetchGroupMembers: fetchGroupMembersUseCase,
            updateMyNickname: updateMyNicknameUseCase
        )
    }
}
