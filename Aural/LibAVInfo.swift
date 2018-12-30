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
        
        if streams.isEmpty {return false}
        
        if let stream = streams.filter({$0.type == .audio}).first {
            return AppConstants.SupportedTypes.nonNativeAudioFormats.contains(stream.format) || stream.format == "flac"
        }
        
        return false
    }
    
    var hasArt: Bool {
        return !streams.isEmpty && streams.filter({$0.type == .art}).count > 0
    }
    
    var audioStream: LibAVStream? {
        return streams.isEmpty ? nil : streams.filter({$0.type == .audio}).first
    }
    
    var audioFormat: String? {
        return audioStream?.format
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
