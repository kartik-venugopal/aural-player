/*
    Encapsulates all information about a single track
 */

import Cocoa
import AVFoundation

class Track: NSObject {
    
    // The filesystem file that contains the audio track represented by this object
    let file: URL
    
    // The audio asset object used to retrieve metadata for this track
    var audioAsset: AVURLAsset?
    
    // All info relating to how this track is displayed
    var displayInfo: DisplayInfo
    
    // All info relating to playback of this track
    var playbackInfo: PlaybackInfo?
    
    // Audio and filesystem information for this track
    var audioAndFileInfo: AudioAndFileInfo?
    
    // Track information is loaded lazily as needed, for optimal performance. This object stores internally used information to keep track of what information has been loaded, and if there were any errors.
    var lazyLoadingInfo: LazyLoadingInfo
    
    // ID3/iTunes metadata
    var metadata: [String: MetadataEntry] = [String: MetadataEntry]()
    
    init(_ file: URL) {
        
        self.file = file
        self.displayInfo = DisplayInfo(file)
        self.lazyLoadingInfo = LazyLoadingInfo()
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
    
    // Sets all metadata used for display within the playlist and Now Playing box
    func setDisplayMetadata(_ artist: String?, _ title: String?, _ art: NSImage?) {
        displayInfo.setMetadata(artist, title, art)
    }
    
    // Loads metadata and audio/filesystem info for display in the "More Info" view
    func loadDetailedInfo() {
        TrackIO.loadDetailedTrackInfo(self)
    }
    
    // Prepares this track for playback
    func prepareForPlayback() {
        TrackIO.prepareForPlayback(self)
    }
}

class DisplayInfo {
    
    var duration: Double    // seconds
    
    // The following three fields are read from the track's metadata
    var artist: String?
    var title: String?
    var art: NSImage?
    
    var conciseName: String
    
    init(_ file: URL) {
        self.duration = 0
        self.conciseName = file.deletingPathExtension().lastPathComponent
    }
    
    func setMetadata(_ artist: String?, _ title: String?, _ art: NSImage?) {
        
        self.artist = artist
        self.title = title
        self.art = art
        
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

class PlaybackInfo {

    // The audio file containing the actual audio samples
    var audioFile: AVAudioFile?
    
    // The total number of frames in the track
    var frames: Int64?
    
    // The sample rate of the track (in Hz)
    var sampleRate: Double?
    
    // Number of audio channels
    var numChannels: Int?
}

class AudioAndFileInfo {
    
    // Filesystem size
    var size: Size?
    
    // Bit rate (in kbps)
    var bitRate: Int?
    
    // Audio format (e.g. "mp3", "aac", or "lpcm")
    var format: String?
}

class LazyLoadingInfo {
    
    // Whether or not the track is ready for playback
    var preparedForPlayback: Bool = false
    
    // Whether or not track metadata and audio/filesystem info has been loaded
    var detailedInfoLoaded: Bool = false
    
    // Error info if track prep fails
    var preparationFailed: Bool = false
    var preparationError: InvalidTrackError?
}

// Encapsulates a single metadata entry
class MetadataEntry {
    
    // Type: e.g. ID3 or iTunes
    let type: MetadataType
    
    // Key or "tag"
    let key: String
    
    let value: String
    
    init(_ type: MetadataType, _ key: String, _ value: String) {
        
        self.type = type
        self.key = key
        self.value = value
    }
    
    // Computes a user-friendly human-readable key, from the original format-specific key.
    // For example the ID3 tag "TALB" is formatted to "Album Name".
    func formattedKey() -> String {
        return MetadataReader.formattedKey(self)
    }
}

// Wrapper around Track that includes its index in the playlist
class IndexedTrack {
    
    var track: Track
    var index: Int
    
    init(_ track: Track, _ index: Int) {
        self.track = track
        self.index = index
    }
}
