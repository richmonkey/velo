import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel: ChatViewModel
    @State private var draft: String = ""

    init(conversationId: String, conversationTitle: String, kind: ConversationSummary.Kind) {
        _viewModel = StateObject(wrappedValue: AppDI.shared.makeChatViewModel(
            conversationId: conversationId,
            conversationTitle: conversationTitle,
            kind: kind
        ))
    }

    var body: some View {
        VStack(spacing: 0) {
            content
            inputBar
        }
        .navigationTitle(viewModel.conversationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.didLoad()
        }
        .onAppear {
            viewModel.refreshTitle()
        }
        .onDisappear {
            viewModel.stopStreaming()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                switch viewModel.kind {
                case .dm:
                    NavigationLink {
                        ConversationSettingsView(conversationId: viewModel.conversationId)
                    } label: {
                        Image(systemName: "info.circle")
                    }
                case .group:
                    NavigationLink {
                        GroupSettingsView(conversationId: viewModel.conversationId)
                    } label: {
                        Image(systemName: "info.circle")
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.viewState {
        case .loading:
            ProgressView()
                .frame(maxHeight: .infinity)
        case .error(let message):
            VStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxHeight: .infinity)
        case .loaded(let messages):
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(messages) { message in
                            MessageBubble(message: message, kind: viewModel.kind, nameResolver: viewModel.displayName)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.last?.id) { lastId in
                    guard let lastId else { return }
                    withAnimation {
                        proxy.scrollTo(lastId, anchor: .bottom)
                    }
                }
            }
        }
    }

    private var inputBar: some View {
        HStack {
            TextField("输入消息", text: $draft)
                .textFieldStyle(.roundedBorder)
                .disabled(viewModel.isSending)
                .onSubmit(sendDraft)
            Button("发送", action: sendDraft)
                .disabled(viewModel.isSending || draft.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding()
    }

    private func sendDraft() {
        let text = draft
        draft = ""
        viewModel.send(text: text)
    }
}

private struct MessageBubble: View {
    let message: ChatMessage
    let kind: ConversationSummary.Kind
    let nameResolver: (String) -> String

    var body: some View {
        if message.isSystemNotice {
            Text(message.text)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(.systemGray6))
                .clipShape(Capsule())
                .frame(maxWidth: .infinity, alignment: .center)
        } else {
            HStack {
                if message.isFromMe { Spacer(minLength: 40) }
                VStack(alignment: message.isFromMe ? .trailing : .leading, spacing: 2) {
                    if kind == .group, !message.isFromMe {
                        Text(nameResolver(message.senderInboxId))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    Text(message.text)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(message.isFromMe ? Color.accentColor : Color(.systemGray5))
                        .foregroundStyle(message.isFromMe ? .white : .primary)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    Text(message.sentAt.formatted(date: .omitted, time: .shortened))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                if !message.isFromMe { Spacer(minLength: 40) }
            }
        }
    }
}
