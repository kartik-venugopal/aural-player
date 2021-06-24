//
//  MockTrack.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

class MockTrack: Track {
    
    let isValid: Bool
    
    override init(_ file: URL) {
        
        self.isValid = true
        super.init(file)
    }
    
    init(_ file: URL, _ isValid: Bool) {
        
        self.isValid = isValid
        super.init(file)
    }
    
    override func validateAudio() {
        
        if !isValid {
            lazyLoadingInfo.preparationFailed(NoAudioTracksError(self))
        }
        
        lazyLoadingInfo.validated = true
    }
    
    override func prepareForPlayback() {
        
        if !isValid {
            
            lazyLoadingInfo.preparationFailed(NoAudioTracksError(self))
            return
        }
        
        if !playbackNativelySupported {
            
            // Transcode the track and let the transcoder prepare the track for playback
            lazyLoadingInfo.needsTranscoding = true
            
        } else {
            
            playbackInfo = PlaybackInfo()
            playbackInfo?.audioFile = MockAVAudioFile()
            playbackInfo?.frames = 44100 * 300
            playbackInfo?.numChannels = 2
            playbackInfo?.sampleRate = 44100
            
            lazyLoadingInfo.preparedForPlayback = true
        }
    }
    
    override func prepareWithAudioFile(_ file: URL) {
        
        playbackInfo = PlaybackInfo()
        playbackInfo?.audioFile = MockAVAudioFile()
        playbackInfo?.frames = 44100 * 300
        playbackInfo?.numChannels = 2
        playbackInfo?.sampleRate = 44100
        
        lazyLoadingInfo.preparedForPlayback = true
    }
}
