import AVFoundation

extension AVAudioFramePosition {
    
    static func fromTrackTime(_ trackTime: Double, _ sampleRate: Double) -> AVAudioFramePosition {
        return AVAudioFramePosition(round(trackTime * sampleRate))
    }
    
    func toTrackTime(_ sampleRate: Double) -> Double {
        return Double(self) / sampleRate
    }
}
