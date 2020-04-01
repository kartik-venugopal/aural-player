import Cocoa
import AVFoundation

/*
    Encapsulates all information about a single track
 */
class Track: NSObject, PlaylistItem {
    
    let playbackNativelySupported: Bool
    let metadataNativelySupported: Bool
    
    // The audio asset object used to retrieve metadata for this track
    var audioAsset: AVURLAsset?
    
    var libAVInfo: LibAVInfo?
    
    // All info relating to how this track is displayed
    let displayInfo: DisplayInfo
    
    // All info relating to how this track is grouped
    let groupingInfo: GroupingInfo
    
    // All info relating to playback of this track
    var playbackInfo: PlaybackInfo?
    
    // Audio information for this track
    var audioInfo: AudioInfo?
    
    // Filesystem information for this track
    let fileSystemInfo: FileSystemInfo
    
    // Track information is loaded lazily as needed, for optimal performance. This object stores internally used information to keep track of what information has been loaded, and if there were any errors.
    let lazyLoadingInfo: LazyLoadingInfo
    
    // ID3/iTunes metadata
    var metadata: [String: MetadataEntry] = [String: MetadataEntry]()
    
    var lyrics: String?
    
    init(_ file: URL) {
        
        self.playbackNativelySupported = AudioUtils.isAudioFilePlaybackNativelySupported(file)
        self.metadataNativelySupported = MetadataUtils.isFileMetadataNativelySupported(file)
        
        self.fileSystemInfo = FileSystemInfo(file)
        self.displayInfo = DisplayInfo(file)
        self.groupingInfo = GroupingInfo()
        self.lazyLoadingInfo = LazyLoadingInfo()
    }
    
    // Filesystem URL
    var file: URL {
        return fileSystemInfo.file
    }
    
    // A name suitable for display within the playlist and Now Playing box
    var conciseDisplayName: String {
        return displayInfo.conciseName
    }
    
    // In seconds
    var duration: Double {
        return displayInfo.duration
    }
    
    // Whether or not the duration has already been computed
    func hasDuration() -> Bool {
        return displayInfo.duration > 0
    }
    
    func setDuration(_ duration: Double) {
        displayInfo.duration = duration
    }
    
    func setPrimaryMetadata(_ artist: String?, _ title: String?, _ album: String?, _ genre: String?, _ duration: Double) {
        
        displayInfo.setMetadata(artist, title, nil)
        
        groupingInfo.artist = artist
        groupingInfo.album = album
        groupingInfo.genre = genre
        
        if duration > 0 {
            displayInfo.duration = duration
        }
    }
    
    func setSecondaryMetadata(_ discNum: Int?, _ totalDiscs: Int?, _ trackNum: Int?, _ totalTracks: Int?, _ lyrics: String?) {
        
        groupingInfo.discNumber = discNum
        groupingInfo.totalDiscs = totalDiscs
        
        groupingInfo.trackNumber = trackNum
        groupingInfo.totalTracks = totalTracks
        
        self.lyrics = lyrics
    }
    
    // Sets all metadata used for display within the playlist and Now Playing box
    func setDisplayMetadata(_ artist: String?, _ title: String?, _ art: CoverArt?) {
        displayInfo.setMetadata(artist, title, art)
    }
    
    // Loads metadata and audio/filesystem info for display in the "More Info" view
    func loadDetailedInfo() {
        TrackIO.loadDetailedInfo(self)
    }
    
    // Prepares this track for playback
    func prepareForPlayback() {
        TrackIO.prepareForPlayback(self)
    }
}

class CoverArt {
    
    var image: NSImage
    var metadata: ImageMetadata?
    
    init(_ image: NSImage, _ metadata: ImageMetadata?) {
        
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

class DisplayInfo {
    
    var duration: Double    // seconds
    
    // The following three fields are read from the track's metadata
    var artist: String?
    var title: String?
    var art: CoverArt?
    
    var conciseName: String
    
    init(_ file: URL) {
        self.duration = 0
        self.conciseName = file.deletingPathExtension().lastPathComponent
    }
    
    func setMetadata(_ artist: String?, _ title: String?, _ art: CoverArt?) {
        
        self.artist = artist
        self.title = title
        
        if art != nil {
            self.art = art
        }
        
        if (title != nil) {
            
            if (artist != nil) {
                self.conciseName = String(format: "%@ - %@", artist!, title!)
            } else {
                self.conciseName = title!
            }
        }
    }
    
    func hasArtistAndTitle() -> Bool {
        return artist != nil && title != nil
    }
}

class GroupingInfo {
    
    // The following fields are read from the track's metadata
    var artist: String?
    var album: String?
    var genre: String?
    
    var discNumber: Int?
    var totalDiscs: Int?
    
    var trackNumber: Int?
    var totalTracks: Int?
}

class PlaybackInfo {

    // The audio file containing the actual audio samples
    var audioFile: AVAudioFile?
    
    // The total number of frames in the track
    var frames: AVAudioFramePosition?
    
    // The sample rate of the track (in Hz)
    var sampleRate: Double?
    
    // Number of audio channels
    var numChannels: Int?
}

class AudioInfo {
    
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
    
    init(_ file: URL) {
        self.file = file
    }
    
    // Filesystem size
    var size: Size?
    var lastModified: Date?
    var creationDate: Date?
    var kindOfFile: String?
    var lastOpened: Date?
}

class LazyLoadingInfo {
    
    // Whether or not the track is ready for playback
    var preparedForPlayback: Bool = false
    
    var needsTranscoding: Bool = false
    
    var primaryInfoLoaded: Bool = false
    var secondaryInfoLoaded: Bool = false
    
    // Whether or not optional track metadata and audio/filesystem info has been loaded
    var detailedInfoLoaded: Bool = false
    
    // Error info if track prep fails
    var preparationFailed: Bool = false
    var preparationError: InvalidTrackError?
    
    func preparationFailed(_ error: InvalidTrackError?) {
        preparationFailed = true
        preparationError = error
    }
}

// Encapsulates a single metadata entry
class MetadataEntry {
    
    // Type: e.g. ID3 or iTunes
    var type: MetadataType
    
    // Key or "tag"
    let key: String
    
    let value: String
    
    init(_ type: MetadataType, _ key: String, _ value: String) {
        
        self.type = type
        self.key = key
        self.value = value
    }
}

// Wrapper around Track that includes its index in the flat playlist
class IndexedTrack: NSObject {
    
    let track: Track
    let index: Int
    
    init(_ track: Track, _ index: Int) {
        self.track = track
        self.index = index
    }
    
    func equals(_ other: IndexedTrack?) -> Bool {
        return other != nil && other!.index == self.index
    }
}

// Wrapper around Track that includes its location within a group in a hierarchical playlist
struct GroupedTrack {
    
    let track: Track
    let group: Group
    
    let trackIndex: Int
    let groupIndex: Int
    
    init(_ track: Track, _ group: Group, _ trackIndex: Int, _ groupIndex: Int) {
        self.track = track
        self.group = group
        self.trackIndex = trackIndex
        self.groupIndex = groupIndex
    }
}
