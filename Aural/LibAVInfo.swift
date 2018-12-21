import Foundation

class LibAVInfo {
    
    var duration: Double
    var stream: LibAVStream?
    var metadata: [String: String]
    var drmProtected: Bool
    
    init(_ duration: Double, _ stream: LibAVStream?, _ metadata: [String: String], _ drmProtected: Bool) {
        
        self.duration = duration
        self.stream = stream
        self.metadata = metadata
        self.drmProtected = drmProtected
    }
    
    var hasValidAudioTrack: Bool {
        return stream != nil
        // TODO: Also check codec/format of audio tracks
    }
    
    var audioFormat: String {
        return stream?.format ?? ""
    }
}

class LibAVStream {
    
    var format: String
    var bitRate: Double?
    var channelCount: Int
    var sampleRate: Double
    
    init(_ format: String, _ bitRate: Double?, _ channelCount: Int, _ sampleRate: Double) {
        
        self.format = format
        self.bitRate = bitRate
        self.channelCount = channelCount
        self.sampleRate = sampleRate
    }
}
