//
//  MockAVFPlaybackContext.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import AVFoundation

class MockAVFPlaybackContext: PlaybackContextProtocol {
    
    var file: URL
    
    var duration: Double
    
    var audioFormat: AVAudioFormat
    
    var sampleRate: Double
    
    var frameCount: Int64
    
    init(file: URL, duration: Double, audioFormat: AVAudioFormat, sampleRate: Double = 44100) {
        
        self.file = file
        self.duration = duration
        self.audioFormat = audioFormat
        self.sampleRate = sampleRate
        self.frameCount = AVAudioFramePosition.fromTrackTime(duration, sampleRate)
    }
    
    func open() throws {
        
    }
    
    func close() {
        
    }
}
