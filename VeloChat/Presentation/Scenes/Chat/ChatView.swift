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
    @FocusState private var isDraftFocused: Bool
    @State private var fullScreenImage: FullScreenImage?

    private var isCameraAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    private var canSendDraft: Bool {
        !viewModel.isSending && !draft.trimmingCharacters(in: .whitespaces).isEmpty
    }

    init(conversationId: String, peerInboxId: String?, conversationTitle: String, kind: ConversationSummary.Kind) {
        _viewModel = StateObject(wrappedValue: AppDI.shared.makeChatViewModel(
            conversationId: conversationId,
            peerInboxId: peerInboxId,
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
        .fullScreenCover(item: $fullScreenImage) { item in
            FullScreenImageView(messageId: item.messageId, data: item.data)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                switch viewModel.kind {
                case .dm:
                    NavigationLink {
                        ConversationSettingsView(conversationId: viewModel.conversationId, peerInboxId: viewModel.peerInboxId)
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
                            MessageBubble(
                                message: message,
                                kind: viewModel.kind,
                                nameResolver: viewModel.displayName,
                                onImageTap: { data in fullScreenImage = FullScreenImage(messageId: message.id, data: data) }
                            )
                            .id(message.id)
                        }
                    }
                    .padding()
                }
                .onTapGesture { isDraftFocused = false }
                .refreshable {
                    let anchorId = messages.first?.id
                    await viewModel.loadMore()
                    if let anchorId {
                        proxy.scrollTo(anchorId, anchor: .top)
                    }
                }
                .onAppear {
                    if let lastId = messages.last?.id {
                        proxy.scrollTo(lastId, anchor: .bottom)
                    }
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
        if let reason = viewModel.disabledReason {
            Text(reason)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.bubbleOther)
        } else if audioRecorder.isRecording {
            recordingBar
        } else {
            HStack(spacing: 10) {
                Menu {
                    Button {
                        showPhotoPicker = true
                    } label: {
                        Label("Choose from Library", systemImage: "photo")
                    }
                    if isCameraAvailable {
                        Button {
                            showCamera = true
                        } label: {
                            Label("Take Photo", systemImage: "camera")
                        }
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(Color.brandPrimary)
                }
                .buttonStyle(.pressable)
                .disabled(viewModel.isSending)

                TextField("Message", text: $draft, axis: .vertical)
                    .font(.system(size: 16))
                    .lineLimit(1...4)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.bubbleOther, in: RoundedRectangle(cornerRadius: 20))
                    .disabled(viewModel.isSending)
                    .focused($isDraftFocused)
                    .onSubmit(sendDraft)

                if canSendDraft {
                    Button(action: sendDraft) {
                        Image(systemName: "paperplane.circle.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(Color.brandPrimary)
                    }
                    .buttonStyle(.pressable)
                } else {
                    Button {
                        startRecording()
                    } label: {
                        Image(systemName: "mic.circle.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(Color.brandPrimary)
                    }
                    .buttonStyle(.pressable)
                    .disabled(viewModel.isSending)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
    }

    private var recordingBar: some View {
        HStack {
            Button("Cancel") {
                audioRecorder.cancelRecording()
            }
            .buttonStyle(.pressable)
            .foregroundStyle(Color.brandPrimary)
            Spacer()
            Text("Recording \(formattedDuration(audioRecorder.elapsed))")
                .foregroundStyle(Color.textSecondary)
            Spacer()
            Button("Done") {
                finishRecording()
            }
            .buttonStyle(.pressable)
            .fontWeight(.semibold)
            .foregroundStyle(Color.brandPrimary)
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

private struct FullScreenImage: Identifiable {
    let id = UUID()
    let messageId: String
    let data: Data
}

private struct FullScreenImageView: View {
    let messageId: String
    let data: Data
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    private var originalImage: UIImage? { UIImage(data: data) }

    private var magnification: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                scale = max(1, min(lastScale * value, 4))
            }
            .onEnded { _ in
                lastScale = scale
                if scale <= 1 {
                    scale = 1
                    lastScale = 1
                    offset = .zero
                    lastOffset = .zero
                }
            }
    }

    private var pan: some Gesture {
        DragGesture()
            .onChanged { value in
                guard scale > 1 else { return }
                offset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
            }
            .onEnded { _ in
                lastOffset = offset
            }
    }

    private func toggleZoom() {
        withAnimation {
            if scale > 1 {
                scale = 1
                lastScale = 1
                offset = .zero
                lastOffset = .zero
            } else {
                scale = 2
                lastScale = 2
            }
        }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let originalImage {
                Image(uiImage: originalImage)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(scale)
                    .offset(offset)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.white.opacity(0.7))
            }

            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(10)
                            .background(.black.opacity(0.5), in: Circle())
                    }
                    .buttonStyle(.pressable)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                Spacer()
            }
        }
        .contentShape(Rectangle())
        .gesture(magnification)
        .simultaneousGesture(pan)
        .onTapGesture(count: 2) { toggleZoom() }
        .onTapGesture(count: 1) { if scale == 1 { dismiss() } }
    }
}

private struct MessageBubble: View {
    let message: ChatMessage
    let kind: ConversationSummary.Kind
    let nameResolver: (String) -> String
    let onImageTap: (Data) -> Void

    var body: some View {
        if message.isSystemNotice {
            let actorName = message.isFromMe ? "Me" : nameResolver(message.senderInboxId)
            Text(message.text.replacingOccurrences(of: "{{actor}}", with: actorName))
                .font(.caption)
                .foregroundStyle(Color.textSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.systemPillBackground)
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
                            .onTapGesture { onImageTap(imageData) }
                    } else if let audioData = message.audioData {
                        VoiceMessageBubble(audioData: audioData, duration: message.audioDuration, isFromMe: message.isFromMe)
                    } else {
                        Text(message.text)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(message.isFromMe ? Color.bubbleSelf : Color.bubbleOther)
                            .foregroundStyle(message.isFromMe ? .white : Color.textPrimary)
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
            .background(isFromMe ? Color.bubbleSelf : Color.bubbleOther)
            .foregroundStyle(isFromMe ? .white : Color.textPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }

    private func formattedDuration(_ duration: TimeInterval) -> String {
        let totalSeconds = Int(duration.rounded())
        return String(format: "%d:%02d", totalSeconds / 60, totalSeconds % 60)
    }
}
