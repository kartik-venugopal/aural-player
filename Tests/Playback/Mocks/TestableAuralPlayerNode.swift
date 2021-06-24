//
//  TestableAuralPlayerNode.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

/*
    Partially mocked subclass of AuralPlayerNode that facilitates unit testing.
 */
class TestableAuralPlayerNode: AuralPlayerNode {

    var sampleRate: Double? = 0
    var sampleTime: AVAudioFramePosition? = -1
    
    override var lastRenderTime: AVAudioTime? {
        
        guard sampleRate != nil && sampleTime != nil else {return nil}
        
        return AVAudioTime()    // Dummy value
    }
    
    // Set the values sampleTime and sampleRate before calling this function.
    override func playerTime(forNodeTime nodeTime: AVAudioTime) -> AVAudioTime? {
        
        guard let rate = sampleRate, let samples = sampleTime else {return nil}
        
        return AVAudioTime(sampleTime: samples, atRate: rate)
    }
    
    var scheduleSegment_callCount: Int = 0
    var scheduleSegment_legacyAPI_callCount: Int = 0
    
    var scheduleSegment_audioFile: AVAudioFile? = nil
    var scheduleSegment_startFrame: AVAudioFramePosition? = nil
    var scheduleSegment_lastFrame: AVAudioFramePosition? = nil
    var scheduleSegment_frameCount: AVAudioFrameCount? = nil
    
    func resetMock() {
        
        sampleRate = 0
        sampleTime = -1
        
        scheduleSegment_callCount = 0
        scheduleSegment_legacyAPI_callCount = 0
        
        scheduleSegment_audioFile = nil
        scheduleSegment_startFrame = nil
        scheduleSegment_lastFrame = nil
        scheduleSegment_frameCount = nil
    }
    
    override func scheduleSegment(_ file: AVAudioFile, startingFrame startFrame: AVAudioFramePosition, frameCount numberFrames: AVAudioFrameCount, at when: AVAudioTime?, completionHandler: AVAudioNodeCompletionHandler? = nil) {
        
        scheduleSegment_callCount += 1
        scheduleSegment_legacyAPI_callCount += 1

        sampleRate = file.processingFormat.sampleRate
        
        scheduleSegment_audioFile = file
        scheduleSegment_startFrame = startFrame
        scheduleSegment_lastFrame = startFrame + AVAudioFramePosition(numberFrames) - 1
        scheduleSegment_frameCount = numberFrames
    }
    
    @available(OSX 10.13, *)
    override func scheduleSegment(_ file: AVAudioFile, startingFrame startFrame: AVAudioFramePosition, frameCount numberFrames: AVAudioFrameCount, at when: AVAudioTime?, completionCallbackType callbackType: AVAudioPlayerNodeCompletionCallbackType, completionHandler: AVAudioPlayerNodeCompletionHandler? = nil) {
        
        scheduleSegment_callCount += 1
        
        sampleRate = file.processingFormat.sampleRate
        
        scheduleSegment_audioFile = file
        scheduleSegment_startFrame = startFrame
        scheduleSegment_lastFrame = startFrame + AVAudioFramePosition(numberFrames) - 1
        scheduleSegment_frameCount = numberFrames
    }
}
