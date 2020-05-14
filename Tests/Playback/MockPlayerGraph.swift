import AVFoundation

class MockPlayerGraph: PlayerGraphProtocol {
    
    var playerNode: AuralPlayerNode = MockPlayerNode(false)
    
    func reconnectPlayerNodeWithFormat(_ format: AVAudioFormat) {
    }
    
    func clearSoundTails() {
    }
    
    func restartAudioEngine() {
    }
}
