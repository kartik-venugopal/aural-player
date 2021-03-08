import AVFoundation

/*
    Utility functions related to audio.
 */
class AudioUtils {
    
    private init() {}
    
    private static let formatDescriptions: [String: String] = [
    
        "mp2": "MPEG Audio Layer II (mp2)",
        "mp3": "MPEG Audio Layer III (mp3)",
        "m4a": "MPEG-4 Audio (m4a)",
        "m4b": "MPEG-4 Audio (m4b)",
        "m4r": "MPEG-4 Audio (m4r)",
        "aac": "Advanced Audio Coding (aac)",
        "alac": "Apple Lossless Audio Codec (alac)",
        "caf": "Apple Core Audio Format (caf)",
        "ac3": "Dolby Digital Audio Coding 3 (ac3)",
        "ac-3": "Dolby Digital Audio Coding 3 (ac3)",
        "wav": "Waveform Audio (wav / wave)",
        "au": "NeXT/Sun Audio (au)",
        "snd": "NeXT/Sun Audio (snd)",
        "sd2": "Sound Designer II (sd2)",
        "aiff": "Audio Interchange File Format (aiff)",
        "aif": "Audio Interchange File Format (aiff)",
        "aifc": "Audio Interchange File Format - Compressed (aiff-c)",
        "adts": "Audio Data Transport Stream (adts)",
        "lpcm": "Linear Pulse-Code Modulation (lpcm)",
        "pcm": "Pulse-Code Modulation (pcm)"
    ]
    
//    static let flacSupported: Bool = {
//        
//        let osVersion = SystemUtils.osVersion
//        return (osVersion.majorVersion == 10 && osVersion.minorVersion >= 13) || osVersion.majorVersion > 10
//    }()
    
    // Normalizes a bit rate by rounding it to the nearest multiple of 32. For ex, a bit rate of 251.5 kbps is rounded to 256 kbps.
//    private static func normalizeBitRate(_ rate: Double) -> Int {
//        return Int(round(rate/32)) * 32
//    }
    
    // Computes a readable format string for an audio track
    private static func getFormat(_ assetTrack: AVAssetTrack) -> String {

        let description = CMFormatDescriptionGetMediaSubType(assetTrack.formatDescriptions.first as! CMFormatDescription)
        return avfFormatDescriptions[description] ?? codeToString(description).trimmingCharacters(in: CharacterSet.init(charactersIn: "."))
    }

    // Converts a four character media type code to a readable string
    static func codeToString(_ code: FourCharCode) -> String {

        let numericCode = Int(code)

        var codeString: String = String (describing: UnicodeScalar((numericCode >> 24) & 255)!)
        codeString.append(String(describing: UnicodeScalar((numericCode >> 16) & 255)!))
        codeString.append(String(describing: UnicodeScalar((numericCode >> 8) & 255)!))
        codeString.append(String(describing: UnicodeScalar(numericCode & 255)!))

        return codeString.trimmingCharacters(in: CharacterSet.whitespaces)
    }
}
