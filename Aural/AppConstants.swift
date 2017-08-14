
import Cocoa
import AVFoundation

/*
A collection of app-level constants
*/
class AppConstants {
    
    // Supported playlist formats
    static let m3u: String = "m3u"
    static let m3u8: String = "m3u8"
 
    static let supportedPlaylistFileTypes: [String] = [m3u, m3u8]
    static let supportedAudioFileTypes: [String] = ["mp3", "m4a", "aac", "aif", "aiff", "aifc", "caf", "wav"]
    
    static let supportedFileTypes_open: [String] = ["mp3", "m4a", "aac", "aif", "aiff", "aifc", "caf", "wav", m3u, m3u8, AVFileTypeMPEGLayer3, AVFileTypeAppleM4A, AVFileTypeAIFF, AVFileTypeAIFC, AVFileTypeCoreAudioFormat, AVFileTypeWAVE]
    
    static let supportedFileTypes_save: [String] = [m3u]
    
    static let audibleRangeMin: Float = 20      // 20 Hz
    static let audibleRangeMax: Float = 20480   // 20 KHz
    
    // Frequency ranges for each of the 3 bands (in Hz)
    static let bass_min: Float = audibleRangeMin
    static let bass_max: Float = 250
    
    static let mid_min: Float = 250
    static let mid_max: Float = 2048
    
    static let treble_min: Float = 2048
    static let treble_max: Float = audibleRangeMax
    
    // Units for different effects parameters
    
    static let eqGainDBUnit: String = "dB"
    static let pitchOctavesUnit: String = "8ve"
    static let timeStretchRateUnit: String = "x"
    static let reverbWetAmountUnit: String = "wet"
    static let reverbDryAmountUnit: String = "dry"
    static let delayTimeSecsUnit: String = "s"
    static let delayFeedbackPercUnit: String = "%"
    static let frequencyHzUnit: String = "Hz"
    static let frequencyKHzUnit: String = "KHz"
    
    // Value conversion constants used when passing values across layers of the app (e.g. the UI uses a range of 0-100 for volume, while the player uses a volume range of 0-1)
    
    static let volumeConversion_UIToPlayer: Float = (1/100) // Divide by 100
    static let volumeConversion_playerToUI: Float = 100     // Multiply by 100
    
    static let panConversion_UIToPlayer: Float = (1/100) // Divide by 100
    static let panConversion_playerToUI: Float = 100     // Multiply by 100
    
    static let pitchConversion_UIToPlayer: Float = 1200     // Multiply by 1200
    static let pitchConversion_playerToUI: Float = (1/1200) // Divide by 1200
    
    // App state/log files
    static let stateFileName = "auralPlayer-state.json"
    static let logFileName = "auralPlayer.log"
    
    // Default user's music directory (default place to look in, when opening/saving files)
    static let musicDirURL: URL = FileSystemUtils.resolveTruePath(URL(fileURLWithPath: NSHomeDirectory() + "/Music")).resolvedURL
    
    // Directory where recordings are temporarily stored, till the user defines the location
    static let recordingDirURL: URL = musicDirURL
    
    // Link to online user guide
    static let userGuideURL: URL = URL(string: "https://rawgit.com/maculateConception/aural-player/master/Documentation/UserGuide.html")!
}
