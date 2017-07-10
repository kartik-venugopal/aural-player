/*
    Encapsulates all information about a single track
*/

import Cocoa
import AVFoundation

class Track: NSObject {
    
    // Track file on some filesystem
    var file: NSURL?
    
    // Used during playback (to avoid reading from disk multiple times)
    var avFile: AVAudioFile?
    
    // Used to display the track in playlist (table), and when no ID3 metadata is available
    var shortDisplayName: String?
    
    // (Optional) ID3 metadata to be used in main display (Now Playing)
    var longDisplayName: (title: String?, artist: String?)?
    
    // ID3 metadata to be used for display
    var metadata: (title: String?, artist: String?, art: NSImage?)?
    var extendedMetadata: [String: String] = [String: String]()

    // Extended info
    var duration: Double?    // seconds
    var size: Size?
    var bitRate: Int?
    var numChannels: Int?
    var format: String?
    var frames: Int64?
    var sampleRate: Double?
    
    var preparedForPlayback: Bool = false
    var detailedInfoLoaded: Bool = false
    
}