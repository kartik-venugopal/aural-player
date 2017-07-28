
import Cocoa

/*
A collection of app-level constants
*/
class AppConstants {
 
    static let supportedAudioFileTypes: [String] = ["mp3", "m4a", "aac", "wav"]
    static let supportedFileTypes_open: [String] = ["mp3", "m4a", "aac", "wav", customPlaylistExtension]
    
    static let customPlaylistExtension: String = "apl"
    static let supportedFileTypes_save: [String] = [customPlaylistExtension]
    
    static let audibleRangeMin: Float = 20      // 20 Hz
    static let audibleRangeMax: Float = 20480   // 20 KHz
    
    // Frequency ranges for each of the 3 bands (in Hz)
    static let bass_min: Float = audibleRangeMin
    static let bass_max: Float = 250
    
    static let mid_min: Float = 250
    static let mid_max: Float = 2000
    
    static let treble_min: Float = 2000
    static let treble_max: Float = audibleRangeMax
    
    // App state/log files
    static let stateFileName = "auralPlayer-state.json"
    static let logFileName = "auralPlayer.log"
    
    // Default user's music directory (default place to look in, when opening/saving files)
    static let musicDirURL: URL = URL(fileURLWithPath: NSHomeDirectory() + "/Music")
    
    // Directory where recordings are temporarily stored, till the user defines the location
    static let recordingDirURL: URL = musicDirURL
}
