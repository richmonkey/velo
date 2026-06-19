import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = AppDI.shared.makeHomeViewModel()
    @State private var showingMe = false
    @State private var showingScan = false
    @State private var showingCreateGroup = false
    @State private var conversationPendingDeletion: ConversationSummary?

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Chats")
                .navigationBarTitleDisplayMode(.inline)
                .task {
                    viewModel.didLoad()
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showingMe = true
                        } label: {
                            Image(systemName: "person.crop.circle")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Button {
                                showingScan = true
                            } label: {
                                Label("Add Contact", systemImage: "person.badge.plus")
                            }
                            Button {
                                showingCreateGroup = true
                            } label: {
                                Label("Create Group", systemImage: "person.3")
                            }
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showingMe) {
                    MeView()
                }
                .sheet(isPresented: $showingScan) {
                    ScanView(onConversationCreated: { conversationId in
                        Task { await viewModel.conversationCreated(conversationId) }
                    })
                }
                .sheet(isPresented: $showingCreateGroup) {
                    CreateGroupMembersView { _ in
                        viewModel.didLoad()
                    }
                }
                .navigationDestination(for: ConversationSummary.self) { conversation in
                    ChatView(
                        conversationId: conversation.id,
                        peerInboxId: conversation.peerInboxId,
                        conversationTitle: conversation.title,
                        kind: conversation.kind
                    )
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.viewState {
        case .loading:
            ProgressView()
        case .empty:
            emptyState
        case .loaded(let conversations):
            List(conversations) { conversation in
                NavigationLink(value: conversation) {
                    ConversationRow(
                        conversation: conversation,
                        unreadCount: viewModel.unreadCounts[conversation.id] ?? 0,
                        isMuted: viewModel.isMuted(conversationId: conversation.id)
                    )
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        conversationPendingDeletion = conversation
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .tint(.red)
                }
            }
            .listStyle(.plain)
            .refreshable {
                await viewModel.refresh()
            }
            .onAppear {
                viewModel.refreshUnreadCounts()
                Task { await viewModel.refresh() }
            }
            .confirmationDialog(
                "Delete Conversation",
                isPresented: Binding(
                    get: { conversationPendingDeletion != nil },
                    set: { if !$0 { conversationPendingDeletion = nil } }
                ),
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    if let target = conversationPendingDeletion {
                        Task { await viewModel.deleteConversation(target.id) }
                    }
                    conversationPendingDeletion = nil
                }
                Button("Cancel", role: .cancel) {
                    conversationPendingDeletion = nil
                }
            } message: {
                Text("This will permanently delete the local chat history for this conversation on this device. This cannot be undone.")
            }
        case .error(let message):
            errorState(message)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("No conversations yet")
                .foregroundStyle(.secondary)
        }
    }

    private func errorState(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundStyle(.red)
            Text("Failed to load conversations")
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
            Button("Retry") {
                viewModel.didLoad()
            }
        }
        .padding()
    }
}

private struct ConversationRow: View {
    let conversation: ConversationSummary
    let unreadCount: Int
    let isMuted: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(conversation.title)
                        .font(.headline)
                        .lineLimit(1)
                    if isMuted {
                        Image(systemName: "bell.slash.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                if let preview = conversation.lastMessagePreview {
                    Text(preview)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer()
            if unreadCount > 0 {
                Text("\(unreadCount)")
                    .font(.caption2.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.unreadBadge, in: Capsule())
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    HomeView()
}
