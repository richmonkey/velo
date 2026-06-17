import SwiftUI
import PhotosUI
import AVFoundation

struct ChatView: View {
    @StateObject private var viewModel: ChatViewModel
    @State private var draft: String = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showPhotoPicker = false
    @State private var showCamera = false
    @StateObject private var audioRecorder = AudioRecorder()

    private var isCameraAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

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
        .onAppear {
            audioRecorder.onAutoStop = { url, duration in
                sendRecording(url: url, duration: duration)
            }
        }
        .onChange(of: selectedPhotoItem) { item in
            guard let item else { return }
            Task {
                defer { selectedPhotoItem = nil }
                guard let data = try? await item.loadTransferable(type: Data.self),
                      let image = UIImage(data: data) else { return }
                sendImage(image)
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraCaptureView { image in
                showCamera = false
                if let image { sendImage(image) }
            }
        }
        .photosPicker(isPresented: $showPhotoPicker, selection: $selectedPhotoItem, matching: .images)
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

    @ViewBuilder
    private var inputBar: some View {
        if audioRecorder.isRecording {
            recordingBar
        } else {
            HStack {
                Menu {
                    Button {
                        showPhotoPicker = true
                    } label: {
                        Label("从相册选择", systemImage: "photo")
                    }
                    if isCameraAvailable {
                        Button {
                            showCamera = true
                        } label: {
                            Label("拍照", systemImage: "camera")
                        }
                    }
                } label: {
                    Image(systemName: "plus.circle")
                }
                .disabled(viewModel.isSending)
                Button {
                    startRecording()
                } label: {
                    Image(systemName: "mic.circle")
                }
                .disabled(viewModel.isSending)
                TextField("输入消息", text: $draft)
                    .textFieldStyle(.roundedBorder)
                    .disabled(viewModel.isSending)
                    .onSubmit(sendDraft)
                Button("发送", action: sendDraft)
                    .disabled(viewModel.isSending || draft.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding()
        }
    }

    private var recordingBar: some View {
        HStack {
            Button("取消") {
                audioRecorder.cancelRecording()
            }
            Spacer()
            Text("录音中 \(formattedDuration(audioRecorder.elapsed))")
                .foregroundStyle(.secondary)
            Spacer()
            Button("完成") {
                finishRecording()
            }
        }
        .padding()
    }

    private func sendDraft() {
        let text = draft
        draft = ""
        viewModel.send(text: text)
    }

    private func sendImage(_ image: UIImage) {
        guard let data = ImageCompressor.compressedJPEGData(from: image) else {
            return
        }
        viewModel.sendImage(data: data, filename: "image.jpg", mimeType: "image/jpeg")
    }

    private func startRecording() {
        audioRecorder.requestPermission { granted in
            guard granted else { return }
            try? audioRecorder.startRecording()
        }
    }

    private func finishRecording() {
        guard let (url, duration) = audioRecorder.stopRecording() else { return }
        sendRecording(url: url, duration: duration)
    }

    private func sendRecording(url: URL, duration: TimeInterval) {
        defer { try? FileManager.default.removeItem(at: url) }
        guard let data = try? Data(contentsOf: url) else { return }
        viewModel.sendVoice(data: data, filename: "voice.m4a", mimeType: "audio/m4a", duration: duration)
    }

    private func formattedDuration(_ duration: TimeInterval) -> String {
        let totalSeconds = Int(duration)
        return String(format: "%d:%02d", totalSeconds / 60, totalSeconds % 60)
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
                    if let imageData = message.imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 220)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    } else if let audioData = message.audioData {
                        VoiceMessageBubble(audioData: audioData, duration: message.audioDuration, isFromMe: message.isFromMe)
                    } else {
                        Text(message.text)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(message.isFromMe ? Color.accentColor : Color(.systemGray5))
                            .foregroundStyle(message.isFromMe ? .white : .primary)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    Text(message.sentAt.formatted(date: .omitted, time: .shortened))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                if !message.isFromMe { Spacer(minLength: 40) }
            }
        }
    }
}

private final class VoicePlayerController: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var isPlaying = false

    private var player: AVAudioPlayer?

    func toggle(data: Data) {
        if isPlaying {
            player?.stop()
            isPlaying = false
            ProximityAudioRouter.shared.endPlayback()
            return
        }
        guard let player = try? AVAudioPlayer(data: data) else { return }
        player.delegate = self
        self.player = player
        ProximityAudioRouter.shared.beginPlayback()
        player.play()
        isPlaying = true
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.isPlaying = false
            ProximityAudioRouter.shared.endPlayback()
        }
    }

    deinit {
        if isPlaying { ProximityAudioRouter.shared.endPlayback() }
    }
}

private struct VoiceMessageBubble: View {
    let audioData: Data
    let duration: TimeInterval?
    let isFromMe: Bool

    @StateObject private var player = VoicePlayerController()

    var body: some View {
        Button {
            player.toggle(data: audioData)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: player.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                Text(formattedDuration(duration ?? 0))
                    .font(.callout)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isFromMe ? Color.accentColor : Color(.systemGray5))
            .foregroundStyle(isFromMe ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }

    private func formattedDuration(_ duration: TimeInterval) -> String {
        let totalSeconds = Int(duration.rounded())
        return String(format: "%d:%02d", totalSeconds / 60, totalSeconds % 60)
    }
}
