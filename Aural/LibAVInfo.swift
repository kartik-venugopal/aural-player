import Foundation

class LibAVInfo {
    
    var duration: Double
    var streams: [LibAVStream]
    var metadata: [String: String]
    var drmProtected: Bool
    
    init(_ duration: Double, _ streams: [LibAVStream], _ metadata: [String: String], _ drmProtected: Bool) {
        
        self.duration = duration
        self.streams = streams
        self.metadata = metadata
        self.drmProtected = drmProtected
    }
    
    var hasValidAudioTrack: Bool {
        
        let numAudioTracks = streams.filter({$0.type == .audio}).count
        return numAudioTracks > 0
        
        // TODO: Also check format of audio tracks
    }
    
    var audioFormat: String {
        return streams.filter({$0.type == .audio})[0].format
    }
}

class LibAVStream {
    
    var type: LibAVStreamType
    var format: String
    
    init(_ type: LibAVStreamType, _ format: String) {
        self.type = type
        self.format = format
    }
}

enum LibAVStreamType {
    
    case audio
    case video
}
