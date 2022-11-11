//
//  MockAVAudioFile.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

class MockAVAudioFile: AVAudioFile {
    
    var _processingFormat: AVAudioFormat
    var _length: AVAudioFramePosition
    var _url: URL
    
    override var url: URL {
        _url
    }
    
    override var processingFormat: AVAudioFormat {
        _processingFormat
    }
    
    override var length: AVAudioFramePosition {
        _length
    }
    
//    override convenience init() {
//        self.init(AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!)
//    }
    
    init(url: URL, processingFormat: AVAudioFormat, duration: Double = 0) {

        self._url = url
        self._processingFormat = processingFormat
        self._length = AVAudioFramePosition.fromTrackTime(duration, processingFormat.sampleRate)
        
        super.init()
    }
}
