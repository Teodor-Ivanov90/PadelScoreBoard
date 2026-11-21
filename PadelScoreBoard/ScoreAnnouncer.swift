import AVFoundation
import Foundation

public final class ScoreAnnouncer {
    static let shared = ScoreAnnouncer()
    private let synthesizer = AVSpeechSynthesizer()
    
    private init() {
        configureAudioSession()
    }
    
    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
//         .duchOthers lowers music instead of stopping it
        try? session.setCategory(.playback, mode: .default, options: [.duckOthers])
        try? session.setActive(true)
    }
    
    public func announce(_ text: String) {
        // Stop any queued announcement so score don't pile up
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.volume = 1.0
        
        synthesizer.speak(utterance)
    }
}
