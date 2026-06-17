import AVFoundation

final class AudioRecorder: NSObject, ObservableObject, AVAudioRecorderDelegate {
    static let maxDuration: TimeInterval = 60

    @Published private(set) var isRecording = false
    @Published private(set) var elapsed: TimeInterval = 0

    /// Called when recording stops on its own after hitting `maxDuration`, since the
    /// recording bar disappears with `isRecording` and the caller needs the file handed
    /// to it directly rather than via an explicit `stopRecording()` call.
    var onAutoStop: ((URL, TimeInterval) -> Void)?

    private var recorder: AVAudioRecorder?
    private var timer: Timer?
    private(set) var fileURL: URL?
    private var isManualStop = false

    func requestPermission(completion: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async { completion(granted) }
        }
    }

    func startRecording() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default)
        try session.setActive(true)

        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".m4a")
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 22050,
            AVNumberOfChannelsKey: 1,
            AVEncoderBitRateKey: 32000,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
        ]
        let recorder = try AVAudioRecorder(url: url, settings: settings)
        recorder.delegate = self
        recorder.record(forDuration: Self.maxDuration)

        self.recorder = recorder
        self.fileURL = url
        isManualStop = false
        isRecording = true
        elapsed = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.elapsed = self?.recorder?.currentTime ?? 0
        }
    }

    @discardableResult
    func stopRecording() -> (url: URL, duration: TimeInterval)? {
        isManualStop = true
        let duration = recorder?.currentTime ?? elapsed
        recorder?.stop()
        finishUp()
        guard let fileURL else { return nil }
        return (fileURL, duration)
    }

    func cancelRecording() {
        isManualStop = true
        recorder?.stop()
        finishUp()
        if let fileURL { try? FileManager.default.removeItem(at: fileURL) }
        fileURL = nil
    }

    private func finishUp() {
        timer?.invalidate()
        timer = nil
        isRecording = false
        try? AVAudioSession.sharedInstance().setActive(false)
    }

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self, !self.isManualStop else { return }
            let duration = self.recorder?.currentTime ?? self.elapsed
            let url = self.fileURL
            self.finishUp()
            if let url {
                self.onAutoStop?(url, duration)
            }
        }
    }
}
