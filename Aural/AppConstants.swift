
import Cocoa
import AVFoundation

/*
    A collection of app-level constants
*/
struct AppConstants {
    
    struct SupportedTypes {

        // Supported playlist file types
        static let m3u: String = "m3u"
        static let m3u8: String = "m3u8"
        static let playlistExtensions: [String] = [m3u, m3u8]
        
        // Supported audio file types/formats
        
        static let nativeAudioExtensions: [String] = ["mp3", "m4a", "aac", "aif", "aiff", "aifc", "caf", "wav", "ac3", "dsf", "dts", "snd", "sd2", ]
//        static let nonNativeAudioExtensions: [String] = ["wma"]
        static let nonNativeAudioExtensions: [String] = ["flac", "wma", "ogg"]
        
        static let allAudioExtensions: [String] = computeAllAudioExtensions()
        
        private static func computeAllAudioExtensions() -> [String] {
            
            var all: [String] = []
            all.append(contentsOf: nativeAudioExtensions)
            all.append(contentsOf: nonNativeAudioExtensions)
            return all
        }
        
        static let audioFormats: [String] = ["mp3", "m4a", "aac", "ac-3", "aif", "aiff", "aifc", "caf", "wav", "lpcm", "flac", "wma", "vorbis", "ogg", "dsf", "dts", "alaw", "ulaw"]
        
        static let avFileTypes: [String] = [AVFileType.mp3.rawValue, AVFileType.m4a.rawValue, AVFileType.aiff.rawValue, AVFileType.aifc.rawValue, AVFileType.caf.rawValue, AVFileType.wav.rawValue, AVFileType.ac3.rawValue]
        
        // File types allowed in the Open file dialog (extensions and UTIs)
        static var all: [String] = allTypes()
        
        private static func allTypes() -> [String] {
            
            var arr = [String]()
            arr.append(contentsOf: allAudioExtensions)
            arr.append(contentsOf: playlistExtensions)
            arr.append(contentsOf: avFileTypes)
            return arr
        }
    }
    
    struct Sound {

        // Audible range (frequencies)
        static let audibleRangeMin: Float = 20      // 20 Hz
        static let audibleRangeMax: Float = 20000   // 20 KHz
        
        static let eq10BandFrequencies: [Float] = [31, 63, 125, 250, 500, 1000, 2000, 4000, 8000, 16000]
        static let eq15BandFrequencies: [Float] = [25, 40, 63, 100, 160, 250, 400, 630, 1000, 1600, 2500, 4000, 6300, 10000, 16000]
        
        // Min/max Equalizer gain
        static let eqGainMin: Float = -20      // -20 dB
        static let eqGainMax: Float = 20      // -20 dB
        
        static let subBass_min: Float = audibleRangeMin
        static let subBass_max: Float = 60
        
        // Frequency ranges for each of the 3 bands (in Hz)
        static let bass_min: Float = audibleRangeMin
        static let bass_max: Float = 250
        
        static let mid_min: Float = bass_max
        static let mid_max: Float = 4000
        
        static let treble_min: Float = mid_max
        static let treble_max: Float = audibleRangeMax
    }
    
    struct Units {

        // Units for different effects parameters
        
        static let eqGainDB: String = "dB"
        static let pitchOctaves: String = "8ve"
        static let timeStretchRate: String = "x"
        static let reverbWetAmount: String = "wet"
        static let reverbDryAmount: String = "dry"
        static let delayTimeSecs: String = "s"
        static let delayFeedbackPerc: String = "%"
        static let frequencyHz: String = "Hz"
        static let frequencyKHz: String = "KHz"
        static let screenRealEstatePixel = "px"
    }
    
    struct ValueConversions {
        
        // Value conversion constants used when passing values across layers of the app (e.g. the UI uses a range of 0-100 for volume, while the audio graph uses a volume range of 0-1)
        
        static let volume_UIToAudioGraph: Float = (1/100) // Divide by 100
        static let volume_audioGraphToUI: Float = 100     // Multiply by 100
        
        static let pan_UIToAudioGraph: Float = (1/100) // Divide by 100
        static let pan_audioGraphToUI: Float = 100     // Multiply by 100
        
        static let pitch_UIToAudioGraph: Float = 1200     // Multiply by 1200
        static let pitch_audioGraphToUI: Float = (1/1200) // Divide by 1200
    }
    
    struct FilesAndPaths {
        
        // Default user's documents directory (where app state and log are written to)
        static let baseDir: URL = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first!).appendingPathComponent("aural", isDirectory: true)
        
        // App state/log files
        static let appStateFileName = "state.json"
        static let appStateFile: URL = baseDir.appendingPathComponent(appStateFileName)
        
        static let logFileName = "aural.log"
        static let logFile: URL = baseDir.appendingPathComponent(logFileName)
        
        // Default user's music directory (default place to look in, when opening/saving files)
        static let musicDir: URL = FileSystemUtils.resolveTruePath(URL(fileURLWithPath: NSHomeDirectory() + "/Music")).resolvedURL
        
        // Directory where recordings are temporarily stored, till the user defines the location
        static let recordingDir: URL = baseDir.appendingPathComponent("recordings", isDirectory: true)
    }
    
    // Link to online user guide
//    static let onlineUserGuideURL: URL = URL(string: "https://rawgit.com/maculateConception/aural-player/master/Documentation/UserGuide.html")!
 
    // Path to bundled PDF user guide file
//    static let pdfUserGuidePath: String = Bundle.main.path(forResource: "UserGuide", ofType: "pdf")!
}
