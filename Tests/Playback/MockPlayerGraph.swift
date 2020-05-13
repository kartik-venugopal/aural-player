import AVFoundation

class MockPlayerGraph: PlayerGraphProtocol {
    
    var playerNode: AuralPlayerNode = MockPlayerNode()
    
    func reconnectPlayerNodeWithFormat(_ format: AVAudioFormat) {
    }
    
    func clearSoundTails() {
    }
    
    func restartAudioEngine() {
    }
}
