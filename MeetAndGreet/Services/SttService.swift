import AVFoundation
import Speech
import Combine

/// Speech-to-Text Service for iOS 14+
final class SttService: NSObject, ObservableObject {
    static let shared = SttService()

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    @Published private(set) var authorizationStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined
    @Published private(set) var isRecording: Bool = false
    @Published private(set) var transcription: String = ""
    @Published private(set) var isFinal: Bool = false
    @Published private(set) var errorMessage: String?

    private override init() {
        super.init()
        speechRecognizer?.delegate = self
    }

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                self?.authorizationStatus = status
                completion(status == .authorized)
            }
        }
    }

    func startRecording() throws {
        clearTranscriptionData()

        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            throw SttError.recognizerUnavailable
        }

        guard authorizationStatus == .authorized else {
            throw SttError.notAuthorized
        }

        stopRecording()

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw SttError.requestCreationFailed
        }

        recognitionRequest.shouldReportPartialResults = true

        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }

            if let result = result {
                DispatchQueue.main.async {
                    self.transcription = result.bestTranscription.formattedString
                    self.isFinal = result.isFinal
                }
            }

            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.stopRecording()
                }
            }
        }

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        isRecording = true
        errorMessage = nil
    }

    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)

        recognitionRequest?.endAudio()
        recognitionTask?.cancel()

        recognitionRequest = nil
        recognitionTask = nil

        isRecording = false

        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
    }

    func clearTranscriptionData() {
        transcription = ""
        isFinal = false
        errorMessage = nil
    }

    func finalizeAndClear() -> String {
        let result = transcription
        clearTranscriptionData()
        return result
    }
}

extension SttService: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if !available && isRecording {
            stopRecording()
            errorMessage = "音声認識が利用できなくなりました"
        }
    }
}

enum SttError: LocalizedError {
    case recognizerUnavailable
    case notAuthorized
    case requestCreationFailed

    var errorDescription: String? {
        switch self {
        case .recognizerUnavailable: return "音声認識が利用できません"
        case .notAuthorized: return "音声認識の権限がありません"
        case .requestCreationFailed: return "認識リクエストの作成に失敗しました"
        }
    }
}
