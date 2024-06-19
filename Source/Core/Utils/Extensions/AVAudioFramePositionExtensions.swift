//
//  AVAudioFramePositionExtensions.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import AVFoundation

extension AVAudioFramePosition {
    
    static func fromPlaybackPosition(_ playbackPosition: Double, _ sampleRate: Double) -> AVAudioFramePosition {
        return AVAudioFramePosition(round(playbackPosition * sampleRate))
    }
    
    func toPlaybackPosition(_ sampleRate: Double) -> Double {
        return Double(self) / sampleRate
    }
}
