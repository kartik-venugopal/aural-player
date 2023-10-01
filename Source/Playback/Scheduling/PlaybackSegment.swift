//
//  PlaybackSegment.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

///
/// An immutable value object that encapsulates all data required by **AuralPlayerNode** to schedule one
/// audio file segment for playback.
/// 
/// Can be cached for reuse (eg. when playing a segment loop).
///
struct PlaybackSegment {

    let session: PlaybackSession
    let playingFile: AVAudioFile

    let startTime: Double
    let endTime: Double

    let firstFrame: AVAudioFramePosition
    let lastFrame: AVAudioFramePosition

    let frameCount: AVAudioFrameCount

    init(_ session: PlaybackSession, _ playingFile: AVAudioFile, _ firstFrame: AVAudioFramePosition, _ lastFrame: AVAudioFramePosition, _ frameCount: AVAudioFrameCount, _ startTime: Double, _ endTime: Double) {

        self.session = session
        self.playingFile = playingFile

        self.startTime = startTime
        self.endTime = endTime

        self.firstFrame = firstFrame
        self.lastFrame = lastFrame

        self.frameCount = frameCount
    }
}
