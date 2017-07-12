
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
}