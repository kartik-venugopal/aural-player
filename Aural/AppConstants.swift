
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
        
        private static let globallyNativeAudioExtensions: [String] = ["aac", "adts", "ac3", "aif", "aiff", "aifc", "caf", "mp3", "m4a", "snd", "au", "sd2", "wav"]
        static let nativeAudioExtensions: [String] = computeNativeAudioExtensions()
        
        private static func computeNativeAudioExtensions() -> [String] {
            
            var exts: [String] = []
            exts.append(contentsOf: globallyNativeAudioExtensions)
            if AudioUtils.flacSupported {exts.append("flac")}
            
            return exts
        }
        
        static let nonNativeAudioContainerExtensions: [String] = ["mka", "ogg"]
        
        private static let globallyNonNativeAudioExtensions: [String] = ["oga", "opus", "wma", "dsf", "mpc", "mp2", "ape", "wv", "dts"]
        static let nonNativeAudioExtensions: [String] = computeNonNativeAudioExtensions()
        
        private static func computeNonNativeAudioExtensions() -> [String] {
            
            var exts: [String] = []
            exts.append(contentsOf: nonNativeAudioContainerExtensions)
            exts.append(contentsOf: globallyNonNativeAudioExtensions)
            if !AudioUtils.flacSupported {exts.append("flac")}
            
            return exts
        }

        // TODO: MPC (Musepack), DTS (Dolby surround), AC3 (Dolby Surround)
        static let allAudioExtensions: [String] = computeAllAudioExtensions()
        
        private static func computeAllAudioExtensions() -> [String] {
            
            var all: [String] = []
            all.append(contentsOf: nativeAudioExtensions)
            all.append(contentsOf: nonNativeAudioExtensions)
            return all
        }
        
        // TODO: Separate AVFoundation formats from FFmpeg ones
        private static let globallyNativeFormats: [String] = ["aac", "mp3", "ac-3", "ac3", "alac", "pcm_alaw", "pcm_s16le", "pcm_f32be", "pcm_f32le", "pcm_f64be", "pcm_f64le", "pcm_s16be", "pcm_u8", "pcm_mulaw", "pcm_s24be", "pcm_s24le", "pcm_s32be", "pcm_s32le", "pcm_s8", "pcm_u16be", "pcm_u16le", "pcm_u24be", "pcm_u24le", "pcm_u32be", "pcm_u32le", "adpcm_ima_wav", "gsm_ms"]
        
        static let nativeAudioFormats: [String] = computeNativeFormats()
        
        private static func computeNativeFormats() -> [String] {
            
            var formats: [String] = []
            formats.append(contentsOf: globallyNativeFormats)
            if AudioUtils.flacSupported {formats.append("flac")}
            
            return formats
        }
        
        private static let globallyNonNativeFormats: [String] = ["ape", "dsd_lsbf", "dsd_lsbf_planar", "dsd_msbf", "dsd_msbf_planar", "mp2", "mp2_at", "mp2float", "musepack", "musepack7", "musepack8", "mpc", "mpc7", "mpc8", "opus", "vorbis", "wavpack", "wmav1", "wmav2", "wmalossless", "wmapro", "wmavoice", "dts"]
        static let nonNativeAudioFormats: [String] = computeNonNativeFormats()
        
        private static func computeNonNativeFormats() -> [String] {
            
            var formats: [String] = []
            formats.append(contentsOf: globallyNonNativeFormats)
            if !AudioUtils.flacSupported {formats.append("flac")}
            
            return formats
        }
        
        static let allAudioFormats: [String] = computeAllFormats()
        
        private static func computeAllFormats() -> [String] {
            
            var formats: [String] = []
            formats.append(contentsOf: nativeAudioFormats)
            formats.append(contentsOf: nonNativeAudioFormats)
            return formats
        }
        
        
        static let avFileTypes: [String] = [AVFileType.mp3.rawValue, AVFileType.m4a.rawValue, AVFileType.aiff.rawValue, AVFileType.aifc.rawValue, AVFileType.caf.rawValue, AVFileType.wav.rawValue, AVFileType.ac3.rawValue]
        
        // File types allowed in the Open file dialog (extensions and UTIs)
        static let all: [String] = allTypes()
        
        private static func allTypes() -> [String] {
            
            var arr = [String]()
            arr.append(contentsOf: allAudioExtensions)
            arr.append(contentsOf: playlistExtensions)
            arr.append(contentsOf: avFileTypes)
            return arr
        }
        
        static let artFormats: [String] = ["mjpeg", "mjpegb", "mjpeg_2000", "mpjpeg", "jpeg2000", "jpegls", "bmp", "png"]
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
