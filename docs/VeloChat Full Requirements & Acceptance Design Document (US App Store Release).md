# VeloChat Full Requirements \& Acceptance Design Document \(US App Store Release\)

## 1\. Document Overview

### 1\.1 Purpose

This document defines the complete functional requirements, page\-level specifications, and detailed acceptance criteria for VeloChat iOS app targeted for **US App Store exclusive launch**\. The app follows core rules: **no manual login, no registered account system, one\-time purchase \(lifetime unlock\), English\-only UI**, built on XMTP decentralized messaging protocol with SwiftUI and Clean Architecture\.

### 1\.2 Core Release Rules \(Non\-Negotiable\)

- **No Account \& No Login**: No username/password login, no mobile/email registration, no third\-party social login\. Identity is fully decentralized via XMTP wallet\-based inbox ID\.

- **One\-Time Purchase Model**: Lifetime full\-feature access via single one\-time purchase; no subscriptions, no in\-app ads, no paywalls for core functions after purchase\.

- **English\-Only Localization**: All UI text, prompts, alerts, system messages, and error content are strictly English; no multi\-language support\.

- **US App Store Compliance**: Fully compliant with Apple App Store Review Guidelines for privacy, purchase mechanism, push notification, and data security\.

### 1\.3 Technical Foundation

- Architecture: Clean Architecture \(Presentation / Domain / Data / Infrastructure\)

- UI Framework: SwiftUI

- Core Protocol: XMTP Decentralized Messaging Protocol \(MLS security standard\)

- Build Tool: XcodeGen \(Project\.yml managed, no manual \.pbxproj edits\)

- Dependency Management: Centralized AppDI\.shared dependency injection

## 2\. Global App\-Wide Requirements \& Acceptance Criteria

### 2\.1 Purchase System \(One\-Time Lifetime Purchase\)

#### Functional Acceptance Points

- App triggers one\-time purchase prompt on first launch for new users; no free trial, no recurring subscription options\.

- Supports Apple In\-App Purchase \(IAP\) one\-time non\-consumable product, fully compliant with US App Store IAP rules\.

- After successful purchase, all core features \(DM, group chat, media message, push notification, group settings\) are permanently unlocked with no time limit\.

- Supports purchase restoration via Apple’s official restore mechanism \(for device reinstall or device switch\)\.

- No hidden in\-app purchases, no upgrade tiers, no secondary paid features\.

- Purchase status is persisted locally and synced with Apple receipt validation; offline access to purchased features is supported\.

#### Global Page Acceptance Points

- All purchase\-related UI text is clear English: “One\-Time Lifetime Purchase”, “Restore Purchase”, “Unlock All Features”\.

- No misleading purchase descriptions; all feature entitlements are explicitly stated on the purchase screen\.

- Purchase failure/success alerts display accurate English error/success messages\.

### 2\.2 Identity \& No\-Login Mechanism

#### Functional Acceptance Points

- App initializes XMTP client automatically on launch without any user login/registration operation\.

- Generates and stores unique XMTPIdentity \(inboxId \+ walletAddress\) locally via secure KeychainService\.

- No user\-identifiable personal data \(phone, email, name\) is collected for identity creation\.

- Identity data is fully encrypted locally; no identity data uploaded to third\-party servers except decentralized XMTP network\.

- Supports persistent identity across app restarts and device reboots\.

### 2\.3 Security \& Privacy \(US App Store Compliance\)

#### Functional Acceptance Points

- All message data adopts IETF MLS security protocol with perfect forward secrecy and post\-compromise security; messages cannot be retroactively decrypted\.

- End\-to\-end encryption for all text, image, and voice messages; quantum\-safe cryptographic rails\.

- Local sensitive data \(client keys, identity info\) is securely stored via iOS Keychain, no plaintext storage\.

- Built\-in XMTP network\-wide spam protection; user block settings take effect across the entire decentralized network\.

- No user data tracking, no analytics collection by default; compliant with Apple Privacy Manifest requirements\.

### 2\.4 Language \& UI Standardization

#### Functional Acceptance Points

- 100% English UI across all pages, buttons, alerts, placeholders, error messages, and system prompts\.

- No system\-level language fallback to other languages; app forces English display regardless of device system language\.

- All text follows US English grammar and spelling standards\.

## 3\. Page\-Level Detailed Requirements \& Acceptance Criteria

### 3\.1 Launch Loading Page \(LoadingView\)

#### Core Function

Display launch loading state and execute automatic XMTP client initialization on app startup\.

#### Functional Acceptance Points

- App shows LoadingView immediately after launch, no blank screen\.

- Triggers InitializeXMTPClientUseCase automatically without user interaction\.

- On XMTP client initialization success: auto\-navigate to HomeView \(Conversation List\)\.

- On initialization failure: display clear English error prompt and retry button\.

- Loading state has animated indicator to avoid static blank loading\.

#### Page必备 Acceptance Points

- Page layout is adaptive for all iPhone screen sizes \(iOS 15\+ compatible\)\.

- Loading hint text: “Initializing decentralized messaging network” \(English only\)\.

- Error state text: “Failed to initialize XMTP network\. Please retry\.” with “Retry” button\.

- No interactive elements during loading except retry button on failure state\.

### 3\.2 Purchase Unlock Page

#### Core Function

Present one\-time lifetime purchase option for new users to unlock all app features; support purchase restoration\.

#### Functional Acceptance Points

- Pop up automatically after successful XMTP initialization for first\-time users\.

- Display clear product description: “One\-Time Purchase \- Lifetime Full Access”\.

- List all unlocked features explicitly: Unlimited DM/Group Chats, Image/Voice Messaging, Push Notifications, Group Customization\.

- Provide two core buttons: “Purchase Now” and “Restore Purchase”\.

- After successful purchase/restore, permanently dismiss the page and enter HomeView\.

- Purchase failure prompts display specific English reasons \(e\.g\., “Payment cancelled”, “Network error, please try again later”\)\.

#### Page必备 Acceptance Points

- Clean, compliant IAP UI matching US App Store visual guidelines\.

- No deceptive text; all purchase rights are fully disclosed\.

- Restore function can correctly verify Apple receipt and unlock features for existing purchasers\.

### 3\.3 Conversation List Page \(HomeView\)

#### Core Function

Display all DM and group conversations, support real\-time message update, unread count statistics, and entry to core functions\.

#### Functional Acceptance Points

- Conversations are sorted by recent activity \(latest message first\) by default\.

- Each conversation item displays: chat type \(DM/Group\), last message preview, message time stamp, unread count badge\.

- Supports pull\-to\-refresh to manually update conversation list and unread counts\.

- Auto\-refresh unread counts and latest message state when the page appears\.

- Complete state adaptation: empty state \(no conversations\), loading state, error state with retry button\.

- Top left icon: entry to Me \(Identity\) page\.

- Top right “\+” button: expand menu with “Scan to Add Contact” and “Create Group” options\.

- Tap any conversation item to jump to corresponding chat page\.

#### Page必备 Acceptance Points

- Empty state display English hint: “No conversations yet\. Scan contacts or create a group to start chatting\.”

- Loading state shows animated loading indicator with “Loading conversations\.\.\.” text\.

- Error state shows “Failed to load conversations” with actionable “Retry” button\.

- Unread count badge is red, high\-contrast, and accurately synchronized with real unread messages\.

- All menu options and button text are standardized English\.

### 3\.4 Me \(Identity \& Sharing\) Page

#### Core Function

Display user’s unique XMTP identity information, support QR code sharing and quick entry to contact scanning\.

#### Functional Acceptance Points

- Accurately display current user’s XMTP inboxId and walletAddress\.

- Generate real\-time valid QR code mapped to user’s inboxId for contact addition\.

- Support system share sheet to share QR code image and inbox ID text\.

- Provide dedicated button to jump to Scan/Add Contact page\.

- Identity information is cached locally and displayed instantly on page entry\.

#### Page必备 Acceptance Points

- Page title: “My Identity”\.

- Label text: “XMTP Inbox ID”, “Wallet Address”, “Share My QR Code”, “Scan to Add Friends”\.

- QR code is clear and scannable by device camera; no blurring or distortion\.

- Share function supports all iOS system sharing channels \(AirDrop, Message, Mail, etc\.\)\.

### 3\.5 Scan / Add Contact Page \(QRScannerViewController\)

#### Core Function

Scan peer’s XMTP QR code to create new DM conversation automatically\.

#### Functional Acceptance Points

- Automatically request camera permission on first entry; display standard English permission prompt description\.

- Real\-time camera scanning, automatically recognize valid XMTP QR code\.

- On valid scan success: trigger StartConversationUseCase, show loading state during conversation creation\.

- Conversation creation success: auto\-dismiss scan page and refresh home conversation list\.

- Scan failure/invalid QR code: display English error prompt “Invalid XMTP QR Code”\.

- Support manual back exit during scanning and loading\.

#### Page必备 Acceptance Points

- Page title: “Scan Contact QR Code”\.

- Scan viewfinder UI is clear and compliant with iOS camera preview specifications\.

- Permission denied state displays hint: “Camera permission is required for scanning\. Please enable in Settings\.” with “Open Settings” button\.

- Loading state text: “Creating new conversation\.\.\.”

### 3\.6 Create Group Page

#### Core Function

Support multi\-contact selection and custom group name setup to create XMTP decentralized group chat\.

#### Functional Acceptance Points

- Step 1: Load all existing contact accounts from local conversation list, support multi\-select of group members\.

- Step 2: Support custom group name input, empty input cannot trigger creation\.

- Trigger CreateGroupUseCase after confirmation, show loading state during group creation\.

- Creation success: auto\-return to HomeView and refresh conversation list to display new group chat\.

- Creation failure: display English error alert with specific failure reason\.

#### Page必备 Acceptance Points

- Step 1 title: “Select Group Members”, Step 2 title: “Set Group Name”\.

- Member list shows valid contacts with inbox ID preview; support select all/deselect all operation\.

- Group name input placeholder: “Enter group name”\.

- Action buttons: “Next”, “Create Group”, “Cancel” \(English only\)\.

### 3\.7 Chat Page \(DM / Group Unified\)

#### Core Function

Support real\-time sending/receiving of text, image, voice messages, message history pagination, and conversation settings entry\.

#### 3\.7\.1 Message Sending \& Receiving Acceptance Points

- Text Message: Support sending plain text via SendMessageUseCase; real\-time display after sending\.

- Image Message: Support selecting from photo library or camera capture; automatic compression via ImageCompressor before upload/send\.

- Voice Message: Support tap\-to\-record, auto\-stop recording logic; send via SendVoiceMessageUseCase and AudioRecorder\.

- Voice message supports proximity sensor adaptation: auto\-switch between earpiece and speaker via ProximityAudioRouter\.

- Message list supports pagination loading via FetchMessagesUseCase; pull\-to\-refresh loads historical messages\.

- Real\-time message streaming via StreamMessagesUseCase; auto\-scroll to bottom when new messages arrive\.

#### 3\.7\.2 Message Display Acceptance Points

- Distinct bubble style and alignment for self messages \(right\) and peer messages \(left\)\.

- Group chat displays sender nickname for non\-self messages via group nickname lookup\.

- System notice messages \(nickname change, member join/leave\) show as centered pill\-style hints with \{\{actor\}\} placeholder correctly replaced\.

- Image message supports full\-screen preview on tap; preview includes pinch\-to\-zoom, drag\-to\-pan, double\-tap zoom, single\-tap dismiss\.

- Voice message bubble displays duration and play/pause control button\.

#### 3\.7\.3 Page必备 Acceptance Points

- Chat page navigation bar shows conversation title \(peer inbox ID for DM / group name for group\)\.

- Navigation bar right icon enters corresponding settings page \(DM Conversation Settings / Group Settings\)\.

- Message input area clearly displays “Type a message” placeholder\.

- All media operation prompts \(camera/photo/record voice\) are English\.

### 3\.8 Conversation Settings Page \(DM\)

#### Core Function

Support editing and saving custom contact notes for single DM conversations\.

#### Functional Acceptance Points

- Load and display saved contact notes via ConversationNoteRepository on page entry\.

- Support free text editing of contact notes; auto\-save after modification\.

- Notes data is persisted locally and synchronized across app restarts\.

#### Page必备 Acceptance Points

- Page title: “Conversation Settings”\.

- Note field label: “Contact Note”, placeholder: “Add custom note for this contact”\.

- Save success prompt: “Note saved successfully”\.

### 3\.9 Group Settings Page

#### Core Function

Support full group information viewing and editing, member list query, and local nickname management\.

#### Functional Acceptance Points

- Edit group name via UpdateGroupNameUseCase; modification takes effect in real time on chat and home page\.

- Edit group announcement via UpdateGroupAnnouncementUseCase; empty announcement displays “Not Set”\.

- Edit personal group nickname via UpdateMyNicknameUseCase; cached via MemberNicknameStore for persistent display\.

- Load full group member list via FetchGroupMembersUseCase; resolve and display member nicknames correctly\.

- Member list marks current user with “Me” indicator\.

- All operation failures trigger unified English alert dialog with error details\.

#### Page必备 Acceptance Points

- Page title: “Group Settings”\.

- Field labels: “Group Name”, “Group Announcement”, “My Nickname”, “Group Members”\.

- All edit/save/cancel buttons use standard English text\.

- Member list loads with pagination and loading state hints\.

## 4\. Push Notification Requirements \& Acceptance Criteria

### 4\.1 Functional Acceptance Points

- App requests iOS push notification permission on first launch with standard English permission description\.

- SetupPushNotificationsUseCase completes device token registration after permission approval\.

- SyncPushSubscriptionsUseCase synchronizes push subscriptions with current conversation list; only active conversations receive remote pushes\.

- PushNotificationManager and AppDelegate correctly handle background/foreground incoming push messages\.

- Push notification content displays standard English message hints without sensitive data leakage\.

### 4\.2 Compliance Acceptance Points

- Fully compliant with Apple push notification rules; no spam push, no unauthorized push trigger\.

- Users can disable push permission via system settings with full function compatibility\.

## 5\. Local Data Persistence \& Unread Count Acceptance

### 5\.1 Unread Message Statistics

- UnreadCountRepository accurately tracks single\-conversation unread message numbers\.

- Home list unread badges refresh in real time with new message streaming\.

- Unread counts are cleared automatically after entering and viewing the chat page\.

### 5\.2 Local Data Persistence

- Contact notes, group nicknames, unread data are persistently stored via independent repositories\.

- KeychainService securely stores client keys and identity data, no data loss after app restart\.

## 6\. Non\-Functional \& Technical Acceptance Criteria

- **Architecture Isolation**: All XMTP protocol and network interactions are encapsulated by XMTPRepository, XMTPClientManager, XMTPConversationManager; UI layer never calls XMTP SDK directly\.

- **Dependency Injection**: All ViewModels, UseCases, Repositories are initialized via AppDI\.shared centralized injection; no hard\-coded dependencies\.

- **Project Standardization**: Project structure fully managed by XcodeGen Project\.yml; no manual \.pbxproj modifications\.

- **Offline Compatibility**: Local cached data can be displayed normally under offline status; network error prompts are unified English\.

- **Performance**: No UI lag during message streaming, media sending, and list refreshing; memory usage meets Apple iOS app standards\.

## 7\. US App Store Launch Final Compliance Checkpoints

- No account registration/login function, fully meets Apple no\-forced\-account rules\.

- One\-time purchase IAP is fully compliant with US App Store IAP guidelines, no subscription trap\.

- All UI and content are English\-only, no multi\-language residual code\.

- Privacy policy is compliant \(no personal data collection, decentralized data storage\)\.

- All error prompts, system messages, and functional texts are standardized US English\.

- No hidden functions, no background data collection, fully meets Apple Review Guidelines\.

> （注：部分内容可能由 AI 生成）
