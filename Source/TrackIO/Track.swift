import Cocoa
import AVFoundation

/*
    Encapsulates all information about a single track
 */
class Track: Hashable, PlayableItem, PlaylistItem {
    
    let file: URL
    let fileExtension: String
    
    var fileType: String
    var audioFormat: String?
    
    var fileSize: Size?
    
    var fileLastModifiedDate: Date?
    var fileCreationDate: Date?
    var fileLastOpenedDate: Date?
    
    let isNativelySupported: Bool
    
    var playbackContext: PlaybackContextProtocol?
    
    var isPlayable: Bool = true
    var validationError: DisplayableError?
    
    var hasPrimaryMetadata: Bool = false
    
    let defaultDisplayName: String
    
    var displayName: String {
        artistTitleString ?? defaultDisplayName
    }
    
    var duration: Double = 0

    var title: String?
    var artist: String?
    
    var artistTitleString: String? {
        
        if let theArtist = artist, let theTitle = title {
            return "\(theArtist) - \(theTitle)"
        }
        
        return title
    }
    
    var albumArtist: String?
    var album: String?
    var genre: String?
    
    var composer: String?
    var conductor: String?
    var performer: String?
    var lyricist: String?
    
    var art: CoverArt?
    
    var trackNumber: Int?
    var totalTracks: Int?
    
    var discNumber: Int?
    var totalDiscs: Int?
    
    var year: Int?
    
    var bpm: Int?
    
    var lyrics: String?
    
    // Generic metadata
    var genericMetadata: [String: MetadataEntry] = [:]
    
    var chapters: [Chapter] = []
    var hasChapters: Bool {!chapters.isEmpty}
    
    init(_ file: URL, fileMetadata: FileMetadata? = nil) {

        self.file = file
        self.fileExtension = file.pathExtension.lowercased()
        self.fileType = file.pathExtension.uppercased()
        self.defaultDisplayName = file.deletingPathExtension().lastPathComponent
        
        self.isNativelySupported = AppConstants.SupportedTypes.nativeAudioExtensions.contains(fileExtension)
        
        if let theFileMetadata = fileMetadata {
            setPrimaryMetadata(from: theFileMetadata)
        }
    }
    
    func setPrimaryMetadata(from allMetadata: FileMetadata) {
        
        self.isPlayable = allMetadata.isPlayable
        self.validationError = allMetadata.validationError
        
        guard let metadata: PrimaryMetadata = allMetadata.primary else {return}
        
        self.title = metadata.title
        self.artist = metadata.artist
        self.albumArtist = metadata.albumArtist
        self.album = metadata.album
        self.genre = metadata.genre
        
        self.composer = metadata.composer
        self.conductor = metadata.conductor
        self.lyricist = metadata.lyricist
        self.performer = metadata.performer
        
        self.trackNumber = metadata.trackNumber
        self.totalTracks = metadata.totalTracks
        
        self.discNumber = metadata.discNumber
        self.totalDiscs = metadata.totalDiscs
        
        self.year = metadata.year
        self.bpm = metadata.bpm
        
        self.duration = metadata.duration
        
        self.art = metadata.art
        
        self.audioFormat = metadata.audioFormat
    }
    
    func loadSecondaryMetadata() {
//        context?.loadSecondaryMetadata()
    }
    
    func loadAllMetadata() {
//        context?.loadAllMetadata()
    }
    
    func prepareForPlayback() throws {
//        try context?.prepareForPlayback()
    }
    
    static func == (lhs: Track, rhs: Track) -> Bool {
        return lhs.file == rhs.file
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(file.path)
    }
}

class LazyLoadingInfo {
    
    // Whether or not the track is ready for playback
    var validated: Bool = false
    var preparedForPlayback: Bool = false
    
    var primaryInfoLoaded: Bool = false
    var secondaryInfoLoaded: Bool = false
    
    var artLoaded: Bool = false
    
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
