import Foundation

class LibAVInfo {
    
    let duration: Double
    let streams: [LibAVStream]
    let metadata: [String: String]
    let drmProtected: Bool
    
    // Computed values
    let hasValidAudioTrack: Bool
    let hasArt: Bool
    let audioStream: LibAVStream?
    let audioFormat: String?
    
    init(_ duration: Double, _ streams: [LibAVStream], _ metadata: [String: String], _ drmProtected: Bool) {
        
        self.duration = duration
        self.streams = streams
        self.metadata = metadata
        self.drmProtected = drmProtected
        
        self.audioStream = streams.isEmpty ? nil : streams.filter({$0.type == .audio}).first
        
        if let stream = audioStream {
            
            hasValidAudioTrack =
                (duration > 0) &&
                (stream.channelCount ?? 0) > 0 &&
                (stream.sampleRate ?? 0) > 0 &&
                AppConstants.SupportedTypes.allAudioFormats.contains(stream.format)
            
        } else {
            
            hasValidAudioTrack = false
        }
        
        if let stream = streams.filter({$0.type == .art}).first {
            hasArt = AppConstants.SupportedTypes.artFormats.contains(stream.format)
        } else {
            hasArt = false
        }
        
        audioFormat = audioStream?.format
    }
}

class LibAVStream {
    
    var type: LibAVStreamType
    var format: String
    
    // These properties only apply to audio streams
    var bitRate: Double?
    var channelCount: Int?
    var sampleRate: Double?
    
    // For audio streams
    init(_ format: String, _ bitRate: Double?, _ channelCount: Int, _ sampleRate: Double) {
        
        self.type = .audio
        self.format = format
        
        self.bitRate = bitRate
        self.channelCount = channelCount
        self.sampleRate = sampleRate
    }
    
    // For video streams (i.e. art)
    init(_ format: String) {
        
        self.type = .art
        self.format = format
    }
}

enum LibAVStreamType: String {
    
    case audio
    case art
    case other
    
    static func fromString(_ string: String) -> LibAVStreamType {
        return LibAVStreamType(rawValue: string) ?? .other
    }
}
