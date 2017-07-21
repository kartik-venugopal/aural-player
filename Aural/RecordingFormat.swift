/*
    An enumeration of all allowed recording file formats
 */

import Cocoa
import AVFoundation

enum RecordingFormat {
    
    case mp3
    case aac
    
    var settings: [String: Any] {
        
        var settings: [String: Any] = [String: Any]()
        settings[AVSampleRateKey] = 44100
        settings[AVNumberOfChannelsKey] = 2
        
        switch self {
            
        case .aac: settings[AVFormatIDKey] = kAudioFormatMPEG4AAC
        case .mp3: settings[AVFormatIDKey] = kAudioFormatMPEGLayer3
        }
        
        return settings
    }
    
    var fileExtension: String {
        
        switch self {
            
        case .aac: return "aac"
        case .mp3: return "mp3"
        }
    }
}
