//
//  RecordingParams.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

public class RecordingParams {
    
    let format: RecordingFormat
    let quality: RecordingQuality
    
    init(_ format: RecordingFormat, _ quality: RecordingQuality) {
        self.format = format
        self.quality = quality
    }
    
    var settings: [String: Any] {
        
        var settings = [String: Any]()
        
        settings[AVFormatIDKey] = format.formatId
        settings[AVEncoderAudioQualityKey] = quality.avAudioQuality
        
        // 44 KHz stereo
        settings[AVSampleRateKey] = 44100
        settings[AVNumberOfChannelsKey] = 2
        
        return settings
    }
}
