/*
    Encapsulates all information about a single track
*/

import Cocoa
import AVFoundation

class Track: NSObject {
    
    // Track file on some filesystem
    var file: URL?
    
    // Used during playback (to avoid reading from disk multiple times)
    var avFile: AVAudioFile?
    
    // Used to load ID3 metadata and duration
    var avAsset: AVURLAsset?
    
    // Used to display the track in playlist (table), and when no ID3 metadata is available
    var shortDisplayName: String?
    
    var duration: Double?    // seconds
    
    // (Optional) ID3 metadata to be used in main display (Now Playing)
    var longDisplayName: (title: String?, artist: String?)?
    
    // ID3 metadata to be used for display
    var metadata: (title: String?, artist: String?, art: NSImage?)?
    var extendedMetadata: [String: String] = [String: String]()

    // Extended info
    var size: Size?
    var bitRate: Int?
    var numChannels: Int?
    var format: String?
    var frames: Int64?
    var sampleRate: Double?
    
    // Used for lazy loading
    var preparedForPlayback: Bool = false
    var detailedInfoLoaded: Bool = false
    
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
