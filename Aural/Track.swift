/*
 Encapsulates all information about a single track
 */

import Cocoa
import AVFoundation

class Track: NSObject {
    
    // TODO: Revisit and refactor the fields here. Make file non-nil
    
    let file: URL
    var avAsset: AVURLAsset?
    
    var displayInfo: DisplayInfo
    
    var playbackInfo: PlaybackInfo?
    var audioAndFileInfo: AudioAndFileInfo?
    var lazyLoadingInfo: LazyLoadingInfo
    
    // ID3 metadata to be used for display
    var metadata: [String: MetadataEntry] = [String: MetadataEntry]()
    
    init(_ file: URL) {
        
        self.file = file
        self.displayInfo = DisplayInfo(file)
        self.lazyLoadingInfo = LazyLoadingInfo()
    }
    
    var conciseDisplayName: String {
        return displayInfo.conciseName
    }
    
    var duration: Double {
        return displayInfo.duration
    }
    
    func hasDuration() -> Bool {
        return displayInfo.duration > 0
    }
    
    func setDuration(_ duration: Double) {
        displayInfo.duration = duration
    }
    
    func setDisplayMetadata(_ artist: String?, _ title: String?, _ art: NSImage?) {
        displayInfo.setMetadata(artist, title, art)
    }
    
    func loadDetailedInfo() {
        TrackIO.loadDetailedTrackInfo(self)
    }
    
    func prepareForPlayback() {
        TrackIO.prepareForPlayback(self)
    }
}

// TODO: Use this
class DisplayInfo {
    
    var duration: Double    // seconds
    
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

// TODO: Use this
class PlaybackInfo {
    
    var avFile: AVAudioFile?
    
    var frames: Int64?
    var sampleRate: Double?
    var numChannels: Int?
}

class AudioAndFileInfo {
    
    var size: Size?
    var bitRate: Int?
    var format: String?
}

class LazyLoadingInfo {
    
    // Used for lazy loading
    var preparedForPlayback: Bool = false
    var detailedInfoLoaded: Bool = false
    
    // Error info if track prep fails
    var preparationFailed: Bool = false
    var preparationError: InvalidTrackError?
}

class MetadataEntry {
    
    let type: MetadataType
    let key: String
    let value: String
    
    init(_ type: MetadataType, _ key: String, _ value: String) {
        self.type = type
        self.key = key
        self.value = value
    }
    
    func formattedKey() -> String {
        
        switch type {
            
        case .common:   return Utils.splitCamelCaseWord(key, true)
            
        case .id3:  return ID3Spec.forKey(key) ?? key
            
        }
    }
}

// Wrapper around Track that includes its index in the playlist
class IndexedTrack {
    
    var track: Track?
    var index: Int?
    
    init(_ track: Track?, _ index: Int?) {
        self.track = track
        self.index = index
    }
}
