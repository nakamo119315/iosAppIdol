import AVFoundation
import Combine

/// Text-to-Speech Service for iOS 14+
final class TtsService: NSObject, ObservableObject {
    static let shared = TtsService()

    private let synthesizer = AVSpeechSynthesizer()

    @Published var rate: Float = 0.5
    @Published var pitch: Float = 1.0
    @Published var volume: Float = 1.0
    @Published private(set) var isSpeaking: Bool = false
    @Published private(set) var isPaused: Bool = false

    var voiceIdentifier: String?
    private var completionHandler: (() -> Void)?

    private override init() {
        super.init()
        synthesizer.delegate = self
        configureAudioSession()
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }

    func applySettings(rate: Float, pitch: Float, volume: Float) {
        self.rate = rate
        self.pitch = pitch
        self.volume = volume
    }

    func speak(_ text: String, completion: (() -> Void)? = nil) {
        stop()

        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = rate
        utterance.pitchMultiplier = pitch
        utterance.volume = volume
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")

        completionHandler = completion
        isSpeaking = true
        isPaused = false
        synthesizer.speak(utterance)
    }

    func pause() {
        guard isSpeaking && !isPaused else { return }
        synthesizer.pauseSpeaking(at: .word)
        isPaused = true
    }

    func resume() {
        guard isSpeaking && isPaused else { return }
        synthesizer.continueSpeaking()
        isPaused = false
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
        isPaused = false
        completionHandler = nil
    }
}

extension TtsService: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            self?.isSpeaking = false
            self?.isPaused = false
            self?.completionHandler?()
            self?.completionHandler = nil
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            self?.isSpeaking = false
            self?.isPaused = false
            self?.completionHandler = nil
        }
    }
}
