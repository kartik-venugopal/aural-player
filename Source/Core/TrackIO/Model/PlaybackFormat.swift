//
// PlaybackFormat.swift
// Aural
// 
// Copyright © 2024 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import AVFoundation

struct PlaybackFormat {
    
    let sampleRate: Double
    let channelCount: AVAudioChannelCount
    
    let layoutTag: AudioChannelLayoutTag?
    let channelBitmapRawValue: UInt32?
    
    init(audioFormat: AVAudioFormat) {
        
        self.sampleRate = audioFormat.sampleRate
        self.channelCount = audioFormat.channelCount
        self.layoutTag = audioFormat.channelLayout?.layoutTag
        
        if self.layoutTag == kAudioChannelLayoutTag_UseChannelBitmap {
            self.channelBitmapRawValue = audioFormat.channelLayout?.layout.pointee.mChannelBitmap.rawValue
        } else {
            self.channelBitmapRawValue = 0
        }
    }
    
    init?(persistentState: PlaybackFormatPersistentState) {
        
        guard let sampleRate = persistentState.sampleRate,
              let channelCount = persistentState.channelCount else {return nil}
        
        self.sampleRate = sampleRate
        self.channelCount = channelCount
        
        self.layoutTag = persistentState.layoutTag
        self.channelBitmapRawValue = persistentState.channelBitmapRawValue
    }
}

extension PlaybackFormat: Hashable {
    
    static func == (lhs: PlaybackFormat, rhs: PlaybackFormat) -> Bool {
        
        if lhs.sampleRate != rhs.sampleRate {
            return false
        }
        
        if lhs.channelCount != rhs.channelCount {
            return false
        }
        
        if lhs.channelCount <= 2 {
            return true
        }
        
        // MARK: Channel count > 2 --------------------------------------------------
        
        if lhs.layoutTag != rhs.layoutTag {
            return false
        }
        
        if lhs.layoutTag == kAudioChannelLayoutTag_UseChannelBitmap {
            return lhs.channelBitmapRawValue == rhs.channelBitmapRawValue
            
        } else {
            return true
        }
    }
    
    func hash(into hasher: inout Hasher) {

        hasher.combine(sampleRate)
        hasher.combine(channelCount)
        hasher.combine(layoutTag)
        hasher.combine(channelBitmapRawValue)
    }
}
