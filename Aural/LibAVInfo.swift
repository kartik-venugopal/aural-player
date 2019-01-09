import Foundation

class LibAVInfo {
    
    let duration: Double
    let fileFormatDescription: String?
    let streams: [LibAVStream]
    let metadata: LibAVMetadata
    let drmProtected: Bool
    
    // Computed values
    let hasValidAudioTrack: Bool
    let hasArt: Bool
    let audioStream: LibAVStream?
    let audioFormat: String?
    
    init(_ duration: Double, _ fileFormatDescription: String?, _ streams: [LibAVStream], _ metadata: [String: String], _ drmProtected: Bool) {
        
        self.duration = duration
        self.fileFormatDescription = fileFormatDescription
        self.streams = streams
        self.metadata = LibAVMetadata(metadata)
        self.drmProtected = drmProtected
        
        self.audioStream = streams.isEmpty ? nil : streams.filter({$0.type == .audio}).first
        
        if let stream = audioStream {
            
            hasValidAudioTrack =
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

class LibAVMetadata {
    
    var map: [String: String]
    
    var commonMetadata: LibAVParserMetadata?
    var wmMetadata: LibAVParserMetadata?
    var vorbisMetadata: LibAVParserMetadata?
    
    init(_ map: [String: String]) {
        self.map = map
    }
}

class LibAVParserMetadata {
    
    var essentialFields: [String: String] = [:]
    var genericFields: [String: String] = [:]
}

class LibAVStream {
    
    let type: LibAVStreamType
    let format: String
    
    // These properties only apply to audio streams
    var formatDescription: String?
    var bitRate: Double?
    var channelCount: Int?
    var channelLayout: String?
    var sampleRate: Double?
    
    // For audio streams
    init(_ format: String, _ formatDescription: String?, _ bitRate: Double?, _ channelCount: Int, _ channelLayout: String?, _ sampleRate: Double) {
        
        self.type = .audio
        self.format = format
        self.formatDescription = formatDescription
        
        self.bitRate = bitRate
        self.channelCount = channelCount
        self.channelLayout = channelLayout
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
