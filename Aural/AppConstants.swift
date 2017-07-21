
import Cocoa

/*
A collection of app-level constants
*/
class AppConstants {
 
    static let supportedAudioFileTypes: [String] = ["mp3", "m4a"]
    static let supportedFileTypes_open: [String] = ["mp3", "m4a", "apl"]
    
    static let customPlaylistExtension: String = "apl"
    static let supportedFileTypes_save: [String] = [customPlaylistExtension]
    
    static let audibleRangeMin: Float = 10      // 10 Hz
    static let audibleRangeMax: Float = 20480   // 20 KHz
    
    static let stateFileName = "auralPlayer-state.json"
    static let logFileName = "auralPlayer.log"
    
    // Default user's music directory (default place to look in, when opening/saving files)
    static let musicDirURL: URL = URL(fileURLWithPath: NSHomeDirectory() + "/Music")
    
    // Directory where recordings are temporarily stored, till the user defines the location
    static let recordingDirURL: URL = musicDirURL
}
