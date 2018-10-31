
import Cocoa
import AVFoundation

/*
    A collection of app-level constants
*/
class AppConstants {
    
    // Supported playlist file types
    static let m3u: String = "m3u"
    static let m3u8: String = "m3u8"
    static let supportedPlaylistFileExtensions: [String] = [m3u, m3u8]
    
    // Supported audio file types/formats
    static let supportedAudioFileExtensions: [String] = ["mp3", "m4a", "aac", "aif", "aiff", "aifc", "caf", "wav"]
    static let supportedAudioFileFormats: [String] = ["mp3", "m4a", "aac", "aif", "aiff", "aifc", "caf", "wav", "lpcm"]
    
    // File types allowed in the Open file dialog (extensions and UTIs)
    static let supportedFileTypes_open: [String] = ["mp3", "m4a", "aac", "aif", "aiff", "aifc", "caf", "wav", m3u, m3u8, AVFileType.mp3.rawValue, AVFileType.m4a.rawValue, AVFileType.aiff.rawValue, AVFileType.aifc.rawValue, AVFileType.caf.rawValue, AVFileType.wav.rawValue]
    
    // Audible range (frequencies)
    static let audibleRangeMin: Double = 20      // 20 Hz
    static let audibleRangeMax: Double = 20480   // 20 KHz
    
    // Min/max Equalizer gain
    static let eqGainMin: Float = -20      // -20 dB
    static let eqGainMax: Float = 20      // -20 dB
    
    // Frequency ranges for each of the 3 bands (in Hz)
    static let bass_min: Double = audibleRangeMin
    static let bass_max: Double = 250
    
    static let mid_min: Double = bass_max
    static let mid_max: Double = 2048
    
    static let treble_min: Double = mid_max
    static let treble_max: Double = audibleRangeMax
    
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
    
    static let screenRealEstatePixelUnit = "px"
    
    // Value conversion constants used when passing values across layers of the app (e.g. the UI uses a range of 0-100 for volume, while the audio graph uses a volume range of 0-1)
    
    static let volumeConversion_UIToAudioGraph: Float = (1/100) // Divide by 100
    static let volumeConversion_audioGraphToUI: Float = 100     // Multiply by 100
    
    static let panConversion_UIToAudioGraph: Float = (1/100) // Divide by 100
    static let panConversion_audioGraphToUI: Float = 100     // Multiply by 100
    
    static let pitchConversion_UIToAudioGraph: Float = 1200     // Multiply by 1200
    static let pitchConversion_audioGraphToUI: Float = (1/1200) // Divide by 1200
    
    // App state/log files
    static let stateFileName = "auralPlayer-state.json"
    static let logFileName = "auralPlayer.log"
    
    // Default user's documents directory (where app state and log are written to)
    static let documentsDirURL: URL = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first!)
    
    static let appStateFileURL: URL = documentsDirURL.appendingPathComponent(stateFileName)
    static let logFileURL: URL = documentsDirURL.appendingPathComponent(logFileName)
    
    // Default user's music directory (default place to look in, when opening/saving files)
    static let musicDirURL: URL = FileSystemUtils.resolveTruePath(URL(fileURLWithPath: NSHomeDirectory() + "/Music")).resolvedURL
    
    // Directory where recordings are temporarily stored, till the user defines the location
    static let recordingDirURL: URL = musicDirURL
    
    // Link to online user guide
    static let onlineUserGuideURL: URL = URL(string: "https://rawgit.com/maculateConception/aural-player/master/Documentation/UserGuide.html")!
 
    // Path to bundled PDF user guide file
    static let pdfUserGuidePath: String = Bundle.main.path(forResource: "UserGuide", ofType: "pdf")!
}
