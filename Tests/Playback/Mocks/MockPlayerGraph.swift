import AVFoundation

class MockPlayerGraph: PlayerGraphProtocol {
    
    var playerNode: AuralPlayerNode = MockPlayerNode(useLegacyAPI: false)
    
    var reconnectedPlayerNodeWithFormat: Bool = false
    var playerConnectionFormat: AVAudioFormat? = nil
    
    func reconnectPlayerNodeWithFormat(_ format: AVAudioFormat) {
        
        reconnectedPlayerNodeWithFormat = true
        playerConnectionFormat = format
    }
    
    func clearSoundTails() {
    }
    
    var audioEngineRestarted: Bool = false
    
    func restartAudioEngine() {
        audioEngineRestarted = true
    }
}
