//
//  RecordingFormat.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
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
    
    case flac
    
//    case opus
    
    // Returns the appropriate recorder settings for this recording format
    var settings: [String: Any] {
        
        var settings = AudioSettings.stereo44K

        switch self {
            
        case .aac: settings[AVFormatIDKey] = kAudioFormatMPEG4AAC
            
        case .alac: settings[AVFormatIDKey] = kAudioFormatAppleLossless
            
        case .aiff: settings[AVFormatIDKey] = kAudioFormatLinearPCM
            
        case .flac: settings[AVFormatIDKey] = kAudioFormatFLAC
            
        }
        
        return settings
    }
    
    var formatId: AudioFormatID {
        
        switch self {
        
        case .aac: return kAudioFormatMPEG4AAC
            
        case .alac: return kAudioFormatAppleLossless
            
        case .aiff: return kAudioFormatLinearPCM
            
        case .flac: return kAudioFormatFLAC
            
        }
    }
    
    // Returns a user-friendly, UI-friendly description of this format
    var description: String {
        
        switch self {
            
        case .aac: return "Advanced Audio Codec (AAC)"
            
        case .alac: return "Apple Lossless Audio Codec (ALAC)"
            
        case .aiff: return "Audio Interchange File Format (AIFF)"
            
        case .flac: return "Free Lossless Audio Codec (FLAC)"
            
        }
    }
    
    // Given a user-friendly description, returns the matching RecordingFormat
    static func formatForDescription(_ description: String) -> RecordingFormat {
        
        switch description {
            
        case aac.description: return .aac
            
        case alac.description: return .alac
            
        case aiff.description: return .aiff
            
        case flac.description: return .flac
            
        // Impossible
        default: return .aac
        
        }
    }
    
    // Returns an appropriate file extension to be used to store recordings of this format to a file
    var fileExtension: String {
        
        switch self {
            
        case .aac: return "m4a"
            
        case .alac: return "m4a"
            
        case .aiff: return "aif"
            
        case .flac: return "flac"
            
        }
    }
}

// Container for recorder audio settings constants
public class AudioSettings {
    
    // Stereo (2 channel) audio with a 44KHz sample rate
    static let stereo44K: [String: Any] = {
        
        var settings = [String: Any]()
        
        settings[AVSampleRateKey] = 44100
        settings[AVNumberOfChannelsKey] = 2
//        settings[AVEncoderAudioQualityKey] = AVAudioQuality.
        
        return settings
    }()
}
