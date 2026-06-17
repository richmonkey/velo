import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = AppDI.shared.makeHomeViewModel()
    @State private var showingMe = false
    @State private var showingScan = false
    @State private var showingCreateGroup = false

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("会话")
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
                                Label("添加联系人", systemImage: "person.badge.plus")
                            }
                            Button {
                                showingCreateGroup = true
                            } label: {
                                Label("创建群组", systemImage: "person.3")
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
                    ScanView(onConversationCreated: {
                        viewModel.didLoad()
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
                        unreadCount: viewModel.unreadCounts[conversation.id] ?? 0
                    )
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
            .onAppear {
                viewModel.refreshUnreadCounts()
                Task { await viewModel.refresh() }
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
            Text("暂无会话")
                .foregroundStyle(.secondary)
        }
    }

    private func errorState(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundStyle(.red)
            Text("加载会话失败")
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
            Button("重试") {
                viewModel.didLoad()
            }
        }
        .padding()
    }
}

private struct ConversationRow: View {
    let conversation: ConversationSummary
    let unreadCount: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(conversation.title)
                    .font(.headline)
                    .lineLimit(1)
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
                    .background(Color.red, in: Capsule())
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    HomeView()
}
