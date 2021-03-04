
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
        
        ///
        /// A list of extensions of files that represent raw audio streams that lack accurate duration information.
        ///
        static let rawAudioFileExtensions: [String] = ["aac", "adts", "ac3", "dts"]
        
        // Supported audio file types/formats
        
        static let nativeAudioExtensions: [String] = ["aac", "adts", "aif", "aiff", "aifc", "caf", "mp1", "mp2", "mp3", "m4a", "m4b", "m4r", "snd", "au", "sd2", "wav"]
        static let nonNativeAudioExtensions: [String] = ["flac", "oga", "opus", "wma", "dsf", "dsd", "dff", "mpc", "ape", "wv", "dts", "mka", "ogg", "ac3", "amr", "aa3", "tta", "tak", "ra", "rm"]

        static let allAudioExtensions: [String] = {nativeAudioExtensions + nonNativeAudioExtensions}()
        
        static let avfFileTypes: [String] = [AVFileType.mp3.rawValue, AVFileType.m4a.rawValue, AVFileType.aiff.rawValue, AVFileType.aifc.rawValue, AVFileType.caf.rawValue, AVFileType.wav.rawValue, AVFileType.ac3.rawValue]
        
        // File types allowed in the Open file dialog (extensions and UTIs)
        static let all: [String] = {allAudioExtensions + playlistExtensions + avfFileTypes}()
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
        
        static let baseDir: URL = FileSystemUtils.resolveTruePath(URL(fileURLWithPath: NSHomeDirectory() + "/Music/aural")).resolvedURL
        
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
}
