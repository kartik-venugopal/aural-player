//
//  AuralPlayerNode.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

///
/// An alias for a callback function that is invoked by the player node upon completion of a scheduled
/// file segment or audio buffer.
///
typealias SessionCompletionHandler = (PlaybackSession) -> Void

///
/// A custom AVAudioPlayerNode that provides a simplified interface for scheduling file segments and buffers.
///
/// Acts as a middleman between schedulers and **AVAudioPlayerNode**, providing the following functions:
///
/// 1. Convenient scheduling functions that convert seek times (in seconds) to audio frame positions.
/// Callers can schedule segments in terms of seek times and do not need to compute segments in
/// terms of audio frames.
///
/// 2. Computation of the current track seek position in seconds (by converting from the node's sampleTime).
///
/// - SeeAlso: `AVAudioPlayerNode`
///
class AuralPlayerNode: AVAudioPlayerNode {

    var completionCallbackType: AVAudioPlayerNodeCompletionCallbackType = .dataPlayedBack
    
    var completionCallbackQueue: DispatchQueue = .global(qos: .userInteractive)
    
    // The start frame for the current playback session (used to calculate seek position). Represents the point in the track at which playback began.
    var startFrame: AVAudioFramePosition = 0
    
    // When calling play, the sampleTime should always be 0, but in reality, is offset by
    // around 1000 frames, which results in inaccurate seeking and seek position reporting.
    // Apply a correction by noting this offset when segment playback begins.
    var numFramesCorrection: AVAudioFramePosition = 0
    
    // Indicates whether or not a correction (see numFramesCorrection for explanation) has already been applied for the currently playing segment.
    // This flag will be reset every time a new segment is scheduled for playback (i.e. whenever the track changes, a loop is added/removed, or seeking is performed).
    var correctionAppliedForSegment: Bool = false

    // Cached seek position (used when looping, to remember last seek position and avoid displaying 0 when player is temporarily stopped at the end of a loop)
    var cachedSeekPosn: Double = 0
    
    // The absolute minimum frame count when scheduling a segment (to prevent crashes in the playerNode).
    static let minFrames: AVAudioFrameCount = 1
    
    // Retrieves the current seek position, in seconds
    var seekPosition: Double {
        
        if let nodeTime = lastRenderTime, let playerTime = playerTime(forNodeTime: nodeTime) {
            cachedSeekPosn = Double(startFrame + playerTime.sampleTime - numFramesCorrection) / playerTime.sampleRate
        }

        // Default to last remembered position when nodeTime is nil
        return cachedSeekPosn
    }
    
    override func play() {
        
        super.play()
        
        // Apply a correction for the initial (non-zero) frame offset when beginning segment playback.
        // The correction should be applied only once per scheduled segment.
        if !correctionAppliedForSegment {

            if let nodeTime = lastRenderTime, let playerTime = playerTime(forNodeTime: nodeTime) {
                numFramesCorrection = playerTime.sampleTime
                
            } else { // Should be impossible
                numFramesCorrection = 0
            }
            
            correctionAppliedForSegment = true
        }
    }
    
    override func pause() {

        // Force an update before pausing (so that the current seek position is available to clients even when paused).
        cachedSeekPosn = seekPosition
        super.pause()
    }
    
    func scheduleFile(session: PlaybackSession, completionHandler: @escaping SessionCompletionHandler,
                         playingFile: AVAudioFile) {

        
        super.scheduleFile(playingFile, at: nil,
                           completionCallbackType: completionCallbackType) {_ in
            
            if PlaybackSession.isCurrent(session) {
                self.resetSeekPositionState()
            }
            
            self.completionCallbackQueue.async {completionHandler(session)}
        }
    }
    
    func scheduleSegment(session: PlaybackSession, completionHandler: @escaping SessionCompletionHandler,
                         startTime: Double, endTime: Double? = nil,
                         playingFile: AVAudioFile, startFrame: AVAudioFramePosition? = nil,
                         immediatePlayback: Bool = true) -> PlaybackSegment? {

        guard let segment = computeSegment(session, startTime, endTime, playingFile, startFrame) else {return nil}
        
        scheduleSegment(segment, completionHandler, immediatePlayback)
        return segment
    }
    
    func resetSeekPositionState(startFrame: AVAudioFramePosition = 0, startTime: Double = 0) {
        
        // Advance the last seek position to the new position
        self.startFrame = startFrame
        cachedSeekPosn = startTime
        
        // Reset this flag for the new segment
        correctionAppliedForSegment = false
        
        if isPlaying, let nodeTime = self.lastRenderTime, let playerTime = self.playerTime(forNodeTime: nodeTime) {
            
            self.numFramesCorrection = playerTime.sampleTime
            self.correctionAppliedForSegment = true
        }
    }

    func scheduleSegment(_ segment: PlaybackSegment, _ completionHandler: @escaping SessionCompletionHandler, _ immediatePlayback: Bool = true) {

        // The start frame and seek position should be reset only if this segment will be played immediately.
        // If it is being scheduled for the future, doing this will cause inaccurate seek position values.
        if immediatePlayback {
            resetSeekPositionState(startFrame: segment.firstFrame, startTime: segment.startTime)
        }
        
        scheduleSegment(segment.playingFile, startingFrame: segment.firstFrame, frameCount: segment.frameCount, at: nil,
                        completionCallbackType: completionCallbackType) {_ in
            
            self.completionCallbackQueue.async {completionHandler(segment.session)}
        }
    }
    
    func scheduleGaplessSegment(session: PlaybackSession, completionHandler: @escaping SessionCompletionHandler,
                         startTime: Double, endTime: Double? = nil,
                         playingFile: AVAudioFile, startFrame: AVAudioFramePosition? = nil,
                         immediatePlayback: Bool = true) -> PlaybackSegment? {

        guard let segment = computeSegment(session, startTime, endTime, playingFile, startFrame) else {return nil}
        
        scheduleGaplessSegment(segment, immediatePlayback: immediatePlayback, completionHandler: completionHandler)
        return segment
    }
    
    func scheduleGaplessSegment(_ segment: PlaybackSegment, immediatePlayback: Bool = true, completionHandler: @escaping SessionCompletionHandler) {

        // The start frame and seek position should be reset only if this segment will be played immediately.
        // If it is being scheduled for the future, doing this will cause inaccurate seek position values.
        if immediatePlayback {
            resetSeekPositionState(startFrame: segment.firstFrame, startTime: segment.startTime)
        }
        
        scheduleSegment(segment.playingFile, startingFrame: segment.firstFrame, frameCount: segment.frameCount, at: nil,
                        completionCallbackType: completionCallbackType) {_ in
            
            if PlaybackSession.isCurrent(segment.session) {
                self.resetSeekPositionState()
            }
            
            self.completionCallbackQueue.async {completionHandler(segment.session)}
        }
    }
    
    ///
    /// Marks the seek position as equal to the currently playing track's duration (i.e. the end of the track).
    /// This is useful when we want the seek position to show as being at the end of the track but don't want
    /// to schedule anything for playback, e.g. when defining a segment loop that extends to the very end of a track while
    /// paused.
    ///
    func seekToEndOfTrack(_ session: PlaybackSession, frameCount: AVAudioFramePosition) {
        
        // Advance the last seek position to the end of the track.
        cachedSeekPosn = session.track.duration
        startFrame = frameCount
    }
    
    func scheduleBuffer(_ buffer: AVAudioPCMBuffer, for session: PlaybackSession, completionHandler: @escaping SessionCompletionHandler, _ startTime: Double? = nil, _ immediatePlayback: Bool = false) {
        
        // The start frame and seek position should be reset only if this segment will be played immediately.
        // If it is being scheduled for the future, doing this will cause inaccurate seek position values.
        if immediatePlayback, let theStartTime = startTime {
            
            // Advance the last seek position to the new position
            cachedSeekPosn = theStartTime
            startFrame = AVAudioFramePosition(theStartTime * buffer.format.sampleRate)
            
            // Reset this flag for the new segment
            correctionAppliedForSegment = false
        }
        
        scheduleBuffer(buffer, completionHandler: {
            self.completionCallbackQueue.async {completionHandler(session)}
        })
    }
    
    private func areStartAndEndTimeValid(_ startTime: Double, _ endTime: Double?) -> Bool {
        
        if let endTime {
            return startTime >= 0 && endTime >= 0 && startTime <= endTime
        }
        
        return startTime >= 0
    }
    
    // Computes an audio file segment. Given seek times, computes the corresponding audio frames.
    func computeSegment(_ session: PlaybackSession, _ startTime: Double, _ endTime: Double? = nil,
                        _ playingFile: AVAudioFile, _ startFrame: AVAudioFramePosition? = nil) -> PlaybackSegment? {
        
        guard let playbackCtx = session.track.playbackContext, areStartAndEndTimeValid(startTime, endTime) else {
            return nil
        }
        
        let sampleRate = playbackCtx.sampleRate
        let lastFrameInFile: AVAudioFramePosition = playbackCtx.frameCount - 1

        // If an exact start frame is specified, use it.
        // Otherwise, multiply sample rate by the new seek time in seconds to obtain the start frame.
        var firstFrame: AVAudioFramePosition = startFrame ?? AVAudioFramePosition.fromPlaybackPosition(startTime, sampleRate)

        var lastFrame: AVAudioFramePosition
        var segmentEndTime: Double

        // Check if end time is specified.
        if let endTime {

            // Use loop end time to calculate the last frame. Ensure the last frame doesn't go past the actual last frame in the file. Rounding may cause this problem.
            lastFrame = min(AVAudioFramePosition.fromPlaybackPosition(endTime, sampleRate), lastFrameInFile)
            segmentEndTime = endTime

        } else {

            // No end time specified, use audio file's total frame count to determine the last frame
            lastFrame = lastFrameInFile
            segmentEndTime = session.track.duration
        }

        // NOTE - Assign to a signed Int value here to account for possible negative values
        var frameCount: Int64 = lastFrame - firstFrame + 1

        // If the frame count is less than the minimum required to continue playback,
        // schedule the minimum frame count for playback, to avoid crashes in the playerNode.
        if frameCount < Self.minFrames {

            frameCount = Int64(Self.minFrames)
            firstFrame = lastFrame - frameCount + 1
        }

        // If startFrame is specified, use it to calculate a precise start time.
        let segmentStartTime: Double = startFrame?.toPlaybackPosition(sampleRate) ?? startTime
        return PlaybackSegment(session, playingFile, firstFrame, lastFrame, AVAudioFrameCount(frameCount),
                               segmentStartTime, segmentEndTime)
    }
}
