import AVFoundation

class MockPlayerGraph: PlayerGraphProtocol {
    
    var playerNode: AVAudioPlayerNode = MockPlayerNode()
    
    func reconnectPlayerNodeWithFormat(_ format: AVAudioFormat) {
    }
    
    func clearSoundTails() {
    }
    
    func restartAudioEngine() {
    }
}
