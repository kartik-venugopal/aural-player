/*
    An enumeration of all allowed recording audio formats
 */

import Cocoa
import AVFoundation

enum RecordingFormat {
    
    // Advanced Audio Codec
    case aac
    
    // Audio Interchange File Format
    case aiff
    
    // Apple Lossless Audio Codec
    case alac
    
    // Returns the appropriate recorder settings for this recording format
    var settings: [String: Any] {
        
        var settings = AudioSettings.stereo44K

        switch self {
            
        case .aac: settings[AVFormatIDKey] = kAudioFormatMPEG4AAC
            
        case .alac: settings[AVFormatIDKey] = kAudioFormatAppleLossless
            
        case .aiff: settings[AVFormatIDKey] = kAudioFormatLinearPCM
            
        }
        
        return settings
    }
    
    // Returns a user-friendly, UI-friendly description of this format
    var description: String {
        
        switch self {
            
        case .aac: return "Advanced Audio Codec (AAC)"
            
        case .alac: return "Apple Lossless Audio Codec (ALAC)"
            
        case .aiff: return "Audio Interchange File Format (AIFF)"
            
        }
    }
    
    // Given a user-friendly description, returns the matching RecordingFormat
    static func formatForDescription(_ description: String) -> RecordingFormat {
        
        switch description {
            
        case RecordingFormat.aac.description: return .aac
            
        case RecordingFormat.alac.description: return .alac
            
        case RecordingFormat.aiff.description: return .aiff
            
        // Impossible
        default: return .aac
        
        }
    }
    
    // Returns an appropriate file extension to be used to store recordings of this format to a file
    var fileExtension: String {
        
        switch self {
            
        case .aac: return "aac"
            
        case .alac: return "m4a"
            
        case .aiff: return "aif"
            
        }
    }
}

// Container for recorder audio settings constants
fileprivate class AudioSettings {
    
    // Stereo (2 channel) audio with a 44KHz sample rate
    static let stereo44K: [String: Any] = {
        
        var settings = [String: Any]()
        
        settings[AVSampleRateKey] = 44100
        settings[AVNumberOfChannelsKey] = 2
        
        return settings
    }()
}
