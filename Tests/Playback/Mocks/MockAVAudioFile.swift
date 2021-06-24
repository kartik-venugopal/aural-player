//
//  MockAVAudioFile.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

class MockAVAudioFile: AVAudioFile {
    
    var _processingFormat: AVAudioFormat
    
    override var processingFormat: AVAudioFormat {
        return _processingFormat
    }
    
    override convenience init() {
        self.init(AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!)
    }
    
    init(_ processingFormat: AVAudioFormat) {
        self._processingFormat = processingFormat
        super.init()
    }
}
