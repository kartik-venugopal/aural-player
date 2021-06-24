//
//  RecordingQuality.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

public enum RecordingQuality: Int {
    
    case min
    
    case low
    
    case medium
    
    case high
    
    case max
    
    var avAudioQuality: AVAudioQuality {
        return AVAudioQuality(rawValue: self.rawValue)!
    }
}
