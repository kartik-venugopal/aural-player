//
//  AVAudioExtensionsTests.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest
import AVFoundation

/*
    Unit tests for the extensions in AVExtensions.swift
 */
class AVAudioExtensionsTests: XCTestCase {

    func testFromTrackTime() {
        
        doTestFromTrackTime(0.0023762843, 22050, 52)
        
        doTestFromTrackTime(0, 44100, 0)
        doTestFromTrackTime(0.0023762843, 44100, 105)
        
        doTestFromTrackTime(23.7892357, 48000, 1141883)
        
        doTestFromTrackTime(99.9999191919767676, 96000, 9599992)
        
        // > 100 hours of music
        doTestFromTrackTime(369273.2398623498, 192000, 70900462054)
    }
    
    private func doTestFromTrackTime(_ trackTime: Double, _ sampleRate: Double, _ expectedFramePos: AVAudioFramePosition) {
        
        // Allow an error margin of one frame on either side of the expected frame position.
        let expectedFramePosRange: ClosedRange<AVAudioFramePosition> = (expectedFramePos - 1)...(expectedFramePos + 1)
        let framePos: AVAudioFramePosition = AVAudioFramePosition.fromTrackTime(trackTime, sampleRate)
        
        XCTAssertTrue(expectedFramePosRange.contains(framePos))
    }

    func testToTrackTime() {
        
        doTestToTrackTime(52, 22050, 0.002358276643991)
        
        doTestToTrackTime(0, 44100, 0)
        doTestToTrackTime(105, 44100, 0.002380952380952)
        
        doTestToTrackTime(1141883, 48000, 23.789229166666667)
        
        doTestToTrackTime(9599992, 96000, 99.999916666666667)
        
        doTestToTrackTime(70900462054, 192000, 369273.239864583333333)
    }
    
    private func doTestToTrackTime(_ framePos: AVAudioFramePosition, _ sampleRate: Double, _ expectedTrackTime: Double) {
        
        let trackTime: Double = framePos.toTrackTime(sampleRate)
        XCTAssertEqual(trackTime, expectedTrackTime, accuracy: 0.001)   // Allow a 1/1000th of a second error margin.
    }
}
