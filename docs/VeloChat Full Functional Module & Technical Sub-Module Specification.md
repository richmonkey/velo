# VeloChat Full Functional Module \& Technical Sub\-Module Specification

## 1\. Document Overview

This document stratifies all core functional modules of VeloChat by business domain and technical architecture\. It provides **module overview, technical implementation details, sub\-module breakdown, and precise functional logic** for each module\. All technical specifications match the app’s Clean Architecture \(Presentation / Domain / Data / Infrastructure\) and XMTP decentralized messaging implementation, complying with US App Store one\-time\-purchase, no\-account, English\-only release standards\.

This document covers all business and underlying technical modules, serving as the definitive technical checklist for development, testing, and acceptance\.

## 2\. Global Technical Base Module

### 2\.1 Module Overview

The underlying base module provides global technical support for the entire app, including architecture scheduling, dependency injection, local persistent storage, network exception handling, and system adaptation\. It is the underlying technical foundation for all business modules\.

### 2\.2 Core Technical Features

Adopts standard iOS Clean Architecture layering; uniformly decouples business logic via use cases; centralized dependency injection; unified global state management; compatible with iOS light/dark mode and multi\-screen adaptation; unified network error capture and prompt mechanism\.

### 2\.3 Sub\-Modules \& Detailed Functional Description

- **App DI Dependency Injection Sub\-Module**: Centralizes all ViewModel, UseCase, Repository instance initialization via `AppDI.shared`; realizes full dependency inversion; no hard\-coded object creation; supports unified module management and unit testing\.

- **Global State Management Sub\-Module**: Maintains app running status, XMTP client initialization status, purchase authorization status, and theme mode status; broadcasts global state changes to synchronize multi\-page UI refresh\.

- **Unified Exception Handling Sub\-Module**: Captures network exceptions, protocol exceptions, storage exceptions, and operation exceptions globally; encapsulates unified English error prompt logic and retry entry; isolates technical errors from UI layer\.

- **System Adaptation Sub\-Module**: Automatically adapts light/dark mode for all pages and colors; adapts all iPhone screen sizes; uniformly processes system permission state callbacks\.

## 3\. XMTP Decentralized Identity \& Client Module

### 3\.1 Module Overview

The core underlying protocol module, responsible for app startup identity initialization, XMTP client lifecycle management, decentralized wallet identity generation and secure storage\. It realizes the core no\-login and no\-account product features\.

### 3\.2 Core Technical Features

Fully encapsulated XMTP SDK calls; UI layer zero direct SDK access; automatic client initialization without user participation; Keychain encrypted storage of private keys and identity data; local identity persistence and network identity synchronization\.

### 3\.3 Sub\-Modules \& Detailed Functional Description

- **XMTP Client Initialization Sub\-Module**: Implemented by `InitializeXMTPClientUseCase`; completes protocol environment detection, network handshake, and client instance creation on app cold start; returns unique `XMTPIdentity` \(inboxId \+ walletAddress\) after success\.

- **Client Lifecycle Management Sub\-Module**: Managed by `XMTPClientManager`; maintains client active/inactive status; processes background suspension and foreground reconnection logic; avoids repeated initialization and resource leakage\.

- **Decentralized Identity Generation Sub\-Module**: Automatically generates anonymous decentralized identity based on XMTP protocol; no user personal data collection; identity data is bound to local device keychain\.

- **Secure Key Storage Sub\-Module**: Implemented by `KeychainService`; encrypts and stores wallet private key, client key, and inbox identity information; prevents plaintext storage; supports identity persistence after app restart and reinstallation recovery\.

## 4\. In\-App Purchase Authorization Module

### 4\.1 Module Overview

Exclusive US App Store shelf module, responsible for one\-time lifetime purchase, Apple receipt verification, purchase restoration, and global feature authorization control\. It realizes full paid feature unlocking logic\.

### 4\.2 Core Technical Features

Based on Apple official IAP non\-consumable one\-time purchase protocol; local persistent purchase authorization cache; real\-time Apple receipt verification; offline authorization validity; no subscription and no secondary charging logic\.

### 4\.3 Sub\-Modules \& Detailed Functional Description

- **Purchase Popup Scheduling Sub\-Module**: Automatically judges first launch status; pops up purchase page only for unauthorized new users; no repeated popup after successful authorization; shields all core functions before unlocking\.

- **Apple IAP Payment Sub\-Module**: Accesses official App Store payment interface; initiates one\-time purchase order; captures payment success, cancellation, and failure callbacks\.

- **Receipt Verification Sub\-Module**: Verifies Apple transaction receipt locally and remotely; calibrates purchase validity; prevents fake authorization; records official transaction ID\.

- **Purchase Restore Sub\-Module**: Calls Apple official restore capability; matches device historical purchase records; automatically unlocks full functions for restored users\.

- **Global Authorization Control Sub\-Module**: Synchronizes purchase status globally; controls enabling/disabling of chat, group creation, push notification and other core functions based on authorization status\.

## 5\. Conversation List Home Module

### 5\.1 Module Overview

App core homepage business module, responsible for loading, sorting, refreshing, and status display of all DM and group conversations, as well as unread message statistics management\.

### 5\.2 Core Technical Features

Real\-time conversation data synchronization based on XMTP protocol; local caching \+ network dual data source; pull\-to\-refresh manual update \+ page appearance automatic refresh; real\-time unread count calculation and badge rendering; multi\-state UI adaptation \(empty/loading/error\)\.

### 5\.3 Sub\-Modules \& Detailed Functional Description

- **Conversation Data Loading Sub\-Module**: Queries local cached conversation list first, then synchronizes network latest data; sorts conversations in descending order by last message active timestamp\.

- **Unread Count Statistics Sub\-Module**: Implemented by `UnreadCountRepository`; counts unread messages of single conversation in real time; refreshes list badge UI synchronously; clears unread count after entering chat page\.

- **Conversation Refresh Sub\-Module**: Supports manual pull\-to\-refresh full data update; triggers automatic refresh and unread count calibration when home page appears\.

- **Multi\-State Rendering Sub\-Module**: Renders empty state \(no conversation\), network loading state, and network error state uniformly; provides one\-click retry reconnection logic for error state\.

- **Home Entrance Scheduling Sub\-Module**: Provides fixed personal center entrance and add\-function dropdown menu entrance; schedules jump logic for scan contact and create group functions\.

## 6\. Contact \& Identity Management Module

### 6\.1 Module Overview

Responsible for user personal decentralized identity display, QR code generation and sharing, peer contact scanning and conversation creation, and local contact data management\.

### 6\.2 Core Technical Features

Real\-time identity data rendering; dynamic QR code generation based on inboxId; system native share sheet adaptation; camera real\-time QR code recognition; automatic DM conversation creation after valid scanning\.

### 6\.3 Sub\-Modules \& Detailed Functional Description

- **Personal Identity Display Sub\-Module**: Parses and displays real\-time XMTP inboxId and wallet address; caches identity data locally to avoid repeated network requests\.

- **Identity QR Code Generation Sub\-Module**: Generates standard scannable QR code mapped to user exclusive inboxId; adapts light/dark mode QR code display effect\.

- **Identity Share Sub\-Module**: Calls iOS system share capability; supports one\-click sharing of QR code image and inbox text information; adapts all system sharing channels\.

- **QR Code Scan Recognition Sub\-Module**: Applies camera permission; realizes real\-time video stream QR code analysis; filters invalid non\-XMTP QR code data\.

- **Automatic Conversation Creation Sub\-Module**: Implemented by `StartConversationUseCase`; automatically creates DM conversation with peer inboxId after successful scanning; refreshes home conversation list after creation\.

## 7\. Group Chat Management Module

### 7\.1 Module Overview

Responsible for decentralized group chat creation, group information editing, group member management, and group nickname customization, supporting full life cycle management of XMTP protocol group conversations\.

### 7\.2 Core Technical Features

Multi\-contact batch selection group creation; protocol\-based group information modification; local nickname cache \+ network synchronization; real\-time group member list resolution and rendering\.

### 7\.3 Sub\-Modules \& Detailed Functional Description

- **Group Creation Sub\-Module**: Implemented by `CreateGroupUseCase`; loads existing contact list for multi\-select; verifies valid group name; completes protocol group creation and local data synchronization\.

- **Group Name Editing Sub\-Module**: Implemented by `UpdateGroupNameUseCase`; modifies network\-side group name information; synchronizes updates to home list and chat page in real time\.

- **Group Announcement Editing Sub\-Module**: Implemented by `UpdateGroupAnnouncementUseCase`; supports empty announcement identification and modification; persistent storage of announcement information\.

- **Personal Group Nickname Sub\-Module**: Implemented by `UpdateMyNicknameUseCase`; caches nickname via `MemberNicknameStore`; resolves and displays sender nickname in group messages\.

- **Group Member List Sub\-Module**: Implemented by `FetchGroupMembersUseCase`; pulls full group member data; marks current user identity; resolves and displays custom nicknames\.

## 8\. Message Chat Core Module

### 8\.1 Module Overview

The core business module of the app, supporting real\-time sending and receiving of text, image, and voice messages, message history pagination loading, real\-time message streaming, and multi\-type message UI rendering\.

### 8\.2 Core Technical Features

XMTP real\-time message stream monitoring; MLS end\-to\-end encryption for all messages; media message compression and transcoding; voice recording and proximity sensor adaptation; paginated historical message loading; automatic bottom scrolling for new messages\.

### 8\.3 Sub\-Modules \& Detailed Functional Description

- **Text Message Send \& Receive Sub\-Module**: Implemented by `SendMessageUseCase`; sends encrypted plain text messages; receives and parses peer text messages in real time\.

- **Image Message Processing Sub\-Module**: Implemented by `SendImageMessageUseCase` \+ `ImageCompressor`; supports camera shooting and album selection; automatic image compression, format adaptation and encrypted transmission; full\-screen preview, zoom and drag gesture recognition for received images\.

- **Voice Message Processing Sub\-Module**: Implemented by `SendVoiceMessageUseCase` \+ `AudioRecorder`; supports tap\-to\-record and auto\-stop recording; realizes voice encoding compression transmission; integrates `ProximityAudioRouter` to automatically switch earpiece/speaker according to proximity sensor\.

- **Message History Pagination Sub\-Module**: Implemented by `FetchMessagesUseCase`; loads historical messages in pages by time axis; supports pull\-to\-refresh to load earlier records\.

- **Real\-Time Message Streaming Sub\-Module**: Implemented by `StreamMessagesUseCase` / `StreamAllMessagesUseCase`; monitors real\-time message push of current conversation; triggers page auto\-scroll to bottom for new messages\.

- **Message UI Rendering Sub\-Module**: Distinguishes self/other message bubble styles and alignment; renders group chat sender nickname; displays centered system pill prompt messages with placeholder replacement\.

## 9\. Conversation Settings Module

### 9\.1 Module Overview

Responsible for DM conversation custom note management and group chat full parameter setting, realizing personalized configuration of single conversation and group conversation\.

### 9\.2 Core Technical Features

Local persistent storage of custom notes; real\-time synchronization of group configuration modification; unified error prompt for configuration operation failure\.

### 9\.3 Sub\-Modules \& Detailed Functional Description

- **DM Contact Note Sub\-Module**: Implemented by `ConversationNoteRepository`; supports real\-time editing and local persistent storage of contact custom notes; loads cached notes synchronously when entering the page\.

- **Group Configuration Synchronization Sub\-Module**: Integrates group name, announcement, and nickname modification logic; uniformly submits modification requests to XMTP protocol layer; synchronizes local cache and network data\.

- **Operation Error Uniform Processing Sub\-Module**: Captures all group setting modification failures; pops up unified English alert prompt; records operation error logs\.

## 10\. Push Notification Module

### 10\.1 Module Overview

Responsible for iOS push notification permission application, device token registration, conversation push subscription synchronization, and background push message parsing and display\.

### 10\.2 Core Technical Features

Compliant with Apple push specification; dynamic push subscription synchronization; background/foreground push message processing; permission state real\-time monitoring\.

### 10\.3 Sub\-Modules \& Detailed Functional Description

- **Push Permission Registration Sub\-Module**: Implemented by `SetupPushNotificationsUseCase`; applies for user push permission on first launch; completes device token registration with Apple APNs server\.

- **Push Subscription Synchronization Sub\-Module**: Implemented by `SyncPushSubscriptionsUseCase`; dynamically synchronizes push subscription list according to user conversation list; ensures only active conversations receive remote pushes\.

- **Push Message Processing Sub\-Module**: Managed by `PushNotificationManager` \+ AppDelegate; parses background and foreground push messages; displays notification prompts and supports click jump to corresponding conversation\.

## 11\. System Settings \& Auxiliary Module

### 11\.1 Module Overview

Covers all system\-level auxiliary functions, including theme switching, system configuration, app information display, user guide, app sharing, and App Store rating functions, meeting full shelf launch auxiliary requirements\.

### 11\.2 Core Technical Features

Global theme state synchronization; local cache of guide state; native system capability call; internal web view loading of privacy policy and terms\.

### 11\.3 Sub\-Modules \& Detailed Functional Description

- **Theme Mode Switching Sub\-Module**: Supports three modes \(follow system/light mode/dark mode\); globally synchronizes color, gradient and icon style after switching; persistent theme state cache\.

- **First Launch Guide Sub\-Module**: Includes multi\-page welcome onboarding guide and in\-app mask operation guide; caches guide completion state locally to avoid repeated pop\-ups\.

- **App Instruction \& About Sub\-Module**: Displays hierarchical standardized English usage instructions; loads app version, build number and product introduction; internally opens privacy policy and terms of service via web view\.

- **App Share Sub\-Module**: Calls iOS native share sheet; supports sharing App Store link, app introduction and icon image\.

- **App Store Rating Sub\-Module**: Jumps to official App Store rating page; complies with Apple rating pop\-up rules, no forced interaction\.

## 12\. Local Data Persistence Module

### 12\.1 Module Overview

Unified local data storage module, responsible for persistent storage of all non\-network real\-time data, ensuring data consistency after app restart and device switching\.

### 12\.2 Core Technical Features

Hierarchical storage classification; isolated repository data management; encrypted storage of sensitive data; normal cache storage of business data\.

### 12\.3 Sub\-Modules \& Detailed Functional Description

- **Sensitive Data Encrypted Storage Sub\-Module**: Relies on KeychainService; stores client keys, wallet private keys and identity data with high encryption level\.

- **Business Data Persistence Sub\-Module**: Managed by independent repositories; realizes persistent storage of contact notes, group member nicknames, and conversation unread counts\.

- **App State Cache Sub\-Module**: Caches purchase authorization state, theme state, guide completion state, and permission state; ensures consistent user experience after app restart\.

## 13\. Module Architecture Summary

All modules of VeloChat follow layered decoupling design: the infrastructure underlying module provides technical support, the domain use case module encapsulates core business logic, and the presentation layer renders UI and interacts with users\. All XMTP protocol interactions are completely encapsulated without SDK leakage, meeting Clean Architecture specifications and US App Store long\-term iteration and review requirements\.

> （注：部分内容可能由 AI 生成）
