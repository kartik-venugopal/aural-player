import AVFoundation

protocol PlayableItem: Hashable {
    
    var duration: Double {get}
}

//protocol PlaybackContextProtocol {
//
//    var file: URL {get}
//
//    var audioFormat: AVAudioFormat {get}
//
//    func open() throws
//
//    func close()
//}
