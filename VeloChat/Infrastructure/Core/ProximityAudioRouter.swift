import AVFoundation
import UIKit

final class ProximityAudioRouter {
    static let shared = ProximityAudioRouter()

    private var activeCount = 0
    private var observer: NSObjectProtocol?

    private init() {}

    func beginPlayback() {
        activeCount += 1
        guard activeCount == 1 else { return }

        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
        try? session.setActive(true)

        UIDevice.current.isProximityMonitoringEnabled = true
        applyRoute(near: UIDevice.current.proximityState)
        observer = NotificationCenter.default.addObserver(
            forName: UIDevice.proximityStateDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.applyRoute(near: UIDevice.current.proximityState)
        }
    }

    func endPlayback() {
        activeCount = max(0, activeCount - 1)
        guard activeCount == 0 else { return }

        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
        observer = nil
        UIDevice.current.isProximityMonitoringEnabled = false
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func applyRoute(near: Bool) {
        let session = AVAudioSession.sharedInstance()
        let isBuiltInRoute = session.currentRoute.outputs.allSatisfy {
            $0.portType == .builtInSpeaker || $0.portType == .builtInReceiver
        }
        guard isBuiltInRoute else { return }
        try? session.overrideOutputAudioPort(near ? .none : .speaker)
    }
}
