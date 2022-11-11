//
//  MockAVFPlaybackContext.swift
//  Tests
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import AVFoundation

class MockAVFPlaybackContext: AVFPlaybackContext {
    
    init(file: URL, duration: Double, audioFormat: AVAudioFormat) {
        
        let audioFile = MockAVAudioFile(url: file, processingFormat: audioFormat, duration: duration)
        super.init(for: audioFile)
    }
    
    override func open() throws {
        
    }
    
    override func close() {
        
    }
}
