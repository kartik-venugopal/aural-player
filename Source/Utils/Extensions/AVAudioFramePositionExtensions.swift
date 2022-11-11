//
//  AVAudioFramePositionExtensions.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import AVFoundation

extension AVAudioFramePosition {
    
    static func fromTrackTime(_ trackTime: Double, _ sampleRate: Double) -> AVAudioFramePosition {
        return AVAudioFramePosition(round(trackTime * sampleRate))
    }
    
    func toTrackTime(_ sampleRate: Double) -> Double {
        return Double(self) / sampleRate
    }
}
