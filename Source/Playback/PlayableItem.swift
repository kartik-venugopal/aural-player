import AVFoundation

protocol PlayableItem: Hashable {
    
    var duration: Double {get}
}

protocol PlaybackContextProtocol {
    
    var file: URL {get}
    
    var duration: Double {get}
    
    var audioFormat: AVAudioFormat {get}
    
    var sampleRate: Double {get}
    
    var frameCount: Int64 {get}
    
    func open() throws

    func close()
}
