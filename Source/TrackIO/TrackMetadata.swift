import Cocoa
import AVFoundation

class FileMetadata {
    
    var playlist: PlaylistMetadata?
    var playback: PlaybackContextProtocol?
    
    var isPlayable: Bool {validationError == nil}
    var validationError: DisplayableError?
}

enum MetadataType {
 
    case playlist, playback
}

struct PlaylistMetadata {
    
    var title: String?
    
    var artist: String?
    var albumArtist: String?
    var performer: String?
    
    var album: String?
    var genre: String?
    
    var trackNumber: Int?
    var totalTracks: Int?
    
    var discNumber: Int?
    var totalDiscs: Int?
    
    var duration: Double = 0
    var durationIsAccurate: Bool = false
    
    var isProtected: Bool?
    
    var chapters: [Chapter] = []
}

struct SecondaryMetadata {
    
    var fileType: String?
    var audioFormat: String?
    
    var composer: String?
    var conductor: String?
    var lyricist: String?
    
    var year: Int?
    
    var bpm: Int?
    
    var art: CoverArt?
    
    var lyrics: String?
    
    var genericMetadata: OrderedMetadataMap = OrderedMetadataMap()
}

class CoverArt {
    
    var image: NSImage
    var metadata: ImageMetadata?
    
    init(_ image: NSImage, _ metadata: ImageMetadata? = nil) {
        
        self.image = image
        self.metadata = metadata
    }
}

class ImageMetadata {
    
    // e.g. JPEG/PNG
    var type: String? = nil
    
    // e.g. 1680x1050
    var dimensions: NSSize? = nil
    
    // e.g. 72x72 DPI
    var resolution: NSSize? = nil
    
    // e.g. RGB
    var colorSpace: String? = nil
    
    // e.g. "sRGB IEC61966-2.1"
    var colorProfile: String? = nil
    
    // e.g. 8 bit
    var bitDepth: Int? = nil

    // True for transparent images like PNGs
    var hasAlpha: Bool? = nil
}

class AudioInfo {
    
    // The total number of frames in the track
    // TODO: This should be of type AVAudioFrameCount?
    var frames: AVAudioFramePosition?
    
    // The sample rate of the track (in Hz)
    var sampleRate: Double?
    
    // Number of audio channels
    var numChannels: Int?
    
    // Bit rate (in kbps)
    var bitRate: Int?
    
    // Audio format (e.g. "mp3", "aac", or "lpcm")
    var format: String?
    
    var codec: String?
    
    var channelLayout: String?
}

class FileSystemInfo {
    
    // The filesystem file that contains the audio track represented by this object
    let file: URL
    let fileName: String
    
    init(_ file: URL) {
        self.file = file
        self.fileName = file.deletingPathExtension().lastPathComponent
    }
    
    // Filesystem size
    var size: Size?
    var lastModified: Date?
    var creationDate: Date?
    var kindOfFile: String?
    var lastOpened: Date?
}

// Encapsulates a single metadata entry
class MetadataEntry {
    
    // Type: e.g. ID3 or iTunes
    var format: MetadataFormat
    
    // Key or "tag"
    let key: String
    
    let value: String
    
    init(_ format: MetadataFormat, _ key: String, _ value: String) {
        
        self.format = format
        self.key = key
        self.value = value
    }
}

/*
    Represents a single chapter marking within a track
 */
class Chapter {
    
    // Title may be changed / corrected after chapter object is created
    var title: String
    
    // Time bounds of this chapter
    let startTime: Double
    let endTime: Double
    let duration: Double
    
    init(_ title: String, _ startTime: Double, _ endTime: Double, _ duration: Double? = nil) {
        
        self.title = title
        
        self.startTime = startTime
        self.endTime = endTime
        
        // Use duration if provided. Otherwise, compute it from the start and end times.
        self.duration = duration == nil ? max(endTime - startTime, 0) : duration!
    }
    
    init(_ ffmpegChapter: FFmpegChapter) {
        
        self.title = ffmpegChapter.title
        
        self.startTime = ffmpegChapter.startTime
        self.endTime = ffmpegChapter.endTime
        
        self.duration = max(endTime - startTime, 0)
    }
    
    // Convenience function to determine if a given track position lies within this chapter's time bounds
    func containsTimePosition(_ seconds: Double) -> Bool {
        return seconds >= startTime && seconds <= endTime
    }
}

// Wrapper around Chapter that includes its parent track and chronological index
class IndexedChapter: Equatable {
    
    // The track to which this chapter belongs
    let track: Track
    
    // The chapter this object represents
    let chapter: Chapter
    
    // The chronological index of this chapter within the track
    let index: Int
    
    init(_ track: Track, _ chapter: Chapter, _ index: Int) {
        
        self.track = track
        self.chapter = chapter
        self.index = index
    }
    
    static func == (lhs: IndexedChapter, rhs: IndexedChapter) -> Bool {
        return lhs.track == rhs.track && lhs.index == rhs.index
    }
    
    func hash(into hasher: inout Hasher) {
        
        hasher.combine(track.file.path)
        hasher.combine(index)
    }
}

class OrderedMetadataMap {
    
    private var map: [String: String] = [:]
    private var array: [(String, String)] = []
    
    subscript(_ key: String) -> String? {
        
        get {map[key]}
        
        set {
            
            if let theValue = newValue {
                
                let valueExistsForKey: Bool = map[key] != nil
                
                map[key] = theValue
                
                if valueExistsForKey {
                    array.removeAll(where: {$0.0 == key})
                }
                
                array.append((key, theValue))
                
            } else {
                
                // newValue is nil, implying that any existing value should be removed for this key.
                _ = map.removeValue(forKey: key)
                array.removeAll(where: {$0.0 == key})
            }
        }
    }
    
    var keyValuePairs: [(key: String, value: String)] {
        array
    }
}


// Denotes the type (format) of a metadata entry
enum MetadataFormat: String {
    
    case common
    case iTunes
    case id3
    case audioToolbox
    case wma
    case vorbis
    case ape
    case other
    
    // Smaller the number, higher the sort order
    var sortOrder: Int {
        
        switch self {
            
        case .common:   return 0
            
        case .iTunes:  return 1
            
        case .id3:  return 2
            
        case .audioToolbox: return 3
            
        case .wma:  return 4
            
        case .vorbis:  return 5
            
        case .ape:  return 6
            
        case .other:    return 7
            
        }
    }
}
