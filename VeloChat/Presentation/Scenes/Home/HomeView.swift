import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = AppDI.shared.makeHomeViewModel()
    @State private var showingMe = false
    @State private var showingScan = false

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
                        Button {
                            showingScan = true
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
                .navigationDestination(for: ConversationSummary.self) { conversation in
                    ChatView(conversationId: conversation.id, conversationTitle: conversation.title)
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
                    ConversationRow(conversation: conversation)
                }
            }
            .refreshable {
                await viewModel.refresh()
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

    var body: some View {
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
        .padding(.vertical, 4)
    }
}

#Preview {
    HomeView()
}
