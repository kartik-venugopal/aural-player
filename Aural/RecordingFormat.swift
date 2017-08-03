/*
    An enumeration of all allowed recording file formats
 
    NOTE - Currently, only AAC is supported. MP3 support is planned.
 */

import Cocoa
import AVFoundation

enum RecordingFormat {
    
    // TODO: Add mp3 recording support
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
