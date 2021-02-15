import Cocoa

class FormatMapper {
    
    private static let nativeFormatsMap: [String: String] = {

        var map = [
            
             "aac": "m4a",
             "alac": "m4a",
             "aiff": "aiff",
             "mp3": "mp3",
             "ac3": "ac3",
             
             "pcm_u8": "aiff",
             "pcm_s8": "caf",
             
             "pcm_mulaw": "caf",
             "pcm_alaw": "caf",
             
             "pcm_f32be": "caf",
             "pcm_f32le": "caf",
             
             "pcm_f64be": "caf",
             "pcm_f64le": "caf",
             
             "pcm_s16be": "caf",
             "pcm_s16le": "caf",
             
             "pcm_s24be": "caf",
             "pcm_s24le": "caf",
             
             "pcm_s32be": "caf",
             "pcm_s32le": "caf",
             
             "adpcm_ima_wav": "caf",
             "gsm_ms": "caf",
             
             "pcm_u16be": "wav",
             "pcm_u16le": "wav",
             
             "pcm_u24be": "wav",
             "pcm_u24le": "wav",
             
             "pcm_u32be": "wav",
             "pcm_u32le": "wav"
            
             ]
        
        if AudioUtils.flacSupported {
            map["flac"] = "flac"
        }
        
        return map
    }()
    
    // Container -> encoder
    private static let encodersMap: [String: String] = ["m4a": "aac"]
    
    private static let nonNativeFormatsMap: [String: String] = {
        
        var map = [
            
             "ape": "aiff",
             "tta": "aiff",
             "tak": "aiff",
             "ra_144": "m4a",
             "ra_288": "m4a",
             "cook": "m4a",
             "ralf": "aiff",
             "sipr": "m4a",
             "dsd_lsbf": "aiff",
             "dsd_lsbf_planar": "aiff",
             "dsd_msbf": "aiff",
             "dsd_msbf_planar": "aiff",
             "wmav1": "m4a",
             "wmav2": "m4a",
             "wmalossless": "m4a",
             "wmapro": "m4a",
             "wmavoice": "m4a",
             "opus": "m4a",
             "vorbis": "m4a",
             "mpc": "m4a",
             "mpc7": "m4a",
             "mpc8": "m4a",
             "musepack": "m4a",
             "musepack7": "m4a",
             "musepack8": "m4a",
             "wavpack": "m4a",
             "dts": "ac3"
        ]
        
        if !AudioUtils.flacSupported {
            map["flac"] = "aiff"
        }
        
        return map
    }()
    
    private static let extensionsMap: [String: String] = {
        
        var map = [
            
             "ape": "aiff",
             "dsf": "aiff",
             "wma": "m4a",
             "opus": "m4a",
             "ogg": "m4a",
             "oga": "m4a",
             "mpc": "m4a",
             "mp2": "m4a",
             "wv": "m4a",
             "mka": "m4a"
        ]
        
        if !AudioUtils.flacSupported {
            map["flac"] = "aiff"
        }
        
        return map
    }()
    
    private static let defaultOutputFileExtension: String = "m4a"
    
    private static let maxSampleRatesMap: [String: Int] = [
        "ac3": 48000
    ]
    
    static func outputFormatForTranscoding(_ track: Track) -> FormatMapping {
        
        let inputFileExtension = track.file.pathExtension.lowercased()
        let audioFormat = track.libAVInfo!.audioFormat!
        var encoder: String?
        var sampleRate: Int?
        
        var outputFileExtension: String?
        var action: TranscoderAction
        
        if AppConstants.SupportedTypes.nonNativeAudioContainerExtensions.contains(inputFileExtension), let outExt = nativeFormatsMap[audioFormat] {
            
            // It is a natively supported format, simply extract it from the container
            action = .transmux
            outputFileExtension = outExt
            
        } else {
            
            // Need to transcode
            action = .transcode
            outputFileExtension = nonNativeFormatsMap[audioFormat] ?? (extensionsMap[inputFileExtension] ?? defaultOutputFileExtension)
            encoder = encodersMap[outputFileExtension!]
        }
        
        sampleRate = maxSampleRatesMap[outputFileExtension!]
        
        return FormatMapping(action, encoder, outputFileExtension!, sampleRate)
    }
}

class FormatMapping {
    
    let outputExtension: String
    let encoder: String?
    let action: TranscoderAction
    let sampleRate: Int?
    
    init(_ action: TranscoderAction, _ encoder: String?, _ outputExtension: String, _ sampleRate: Int?) {
        
        self.action = action
        self.encoder = encoder
        self.outputExtension = outputExtension
        self.sampleRate = sampleRate
    }
}

enum TranscoderAction {
    
    case transmux
    case transcode
}
