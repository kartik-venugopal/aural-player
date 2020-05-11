import Cocoa
import AVFoundation

/*
    Manages audio scheduling, and playback. See PlaybackSchedulerProtocol for more details on all the functions provided.
 */
@available(OSX 10.13, *)
class NewScheduler: PlaybackSchedulerProtocol {

    // Player node used for actual playback
    private var playerNode: AVAudioPlayerNode

    // The start frame for the current playback session (used to calculate seek position). Represents the point in the track at which playback began.
    private var startFrame: AVAudioFramePosition = 0

    // Cached seek position (used when looping, to remember last seek position and avoid displaying 0 when player is temporarily stopped at the end of a loop)
    private var lastSeekPosn: Double = 0
    
    private var completedWhilePaused: Bool = false

    // Caches a previously computed/scheduled playback segment, when a segment loop is defined, in order to prevent redundant computations.
    private var loopingSegment: PlaybackSegment?

    init(_ playerNode: AVAudioPlayerNode) {
        self.playerNode = playerNode
    }

    // Start track playback from a given position expressed in seconds
    func playTrack(_ session: PlaybackSession, _ startPosition: Double) {
        seekToTime(session, startPosition, true)
    }

    // Seeks to a certain position (seconds) in the specified track. Returns the calculated start frame.
    func seekToTime(_ session: PlaybackSession, _ startTime: Double, _ beginPlayback: Bool) {
        
        // If a complete loop is defined (i.e. seeking within a loop), call playLoop() instead.
        if session.hasCompleteLoop() {
            
            playLoop(session, startTime, beginPlayback)
            return
        }
        
        // If end of track is reached and the player is paused, don't do any scheduling ... simply mark the completedWhilePaused flag.
        if startTime >= session.track.duration && !playerNode.isPlaying {
            completedWhilePaused = true
            return
        }
        
        // Halt current playback
        stop()

        _ = scheduleSegment(session, .dataPlayedBack, {(callbackType: AVAudioPlayerNodeCompletionCallbackType) -> Void in
            
            DispatchQueue.global(qos: .userInteractive).async {
                self.segmentCompleted(session)
            }
            
        }, true, startTime)

        // Don't start playing if player is paused
        if beginPlayback {
            playerNode.play()
        }
    }

    private func scheduleSegment(_ session: PlaybackSession, _ callbackType: AVAudioPlayerNodeCompletionCallbackType, _ completionHandler: ((AVAudioPlayerNodeCompletionCallbackType) -> Void)?, _ immediatePlayback: Bool, _ startTime: Double, _ endTime: Double? = nil) -> PlaybackSegment? {

        if let segment = computeSegment(session, startTime, endTime) {

            doScheduleSegment(segment, callbackType, completionHandler, immediatePlayback)
            return segment
        }

        return nil
    }

    private func doScheduleSegment(_ segment: PlaybackSegment, _ callbackType: AVAudioPlayerNodeCompletionCallbackType, _ completionHandler: ((AVAudioPlayerNodeCompletionCallbackType) -> Void)?, _ immediatePlayback: Bool) {

        // The start frame and seek position should be reset only if this segment will be played immediately.
        // If it is being scheduled for the future, doing this will cause inaccurate seek position values.
        if immediatePlayback {
            
            // Advance the last seek position to the new position
            startFrame = segment.firstFrame
            lastSeekPosn = segment.startTime
        }

        // Schedule a segment beginning at the seek time, with the calculated frame count reflecting the remaining audio frames in the file
        playerNode.scheduleSegment(segment.playingFile, startingFrame: segment.firstFrame, frameCount: segment.frameCount, at: nil, completionCallbackType: callbackType, completionHandler: completionHandler)
    }

    private func computeSegment(_ session: PlaybackSession, _ startTime: Double, _ endTime: Double? = nil) -> PlaybackSegment? {

        if let playingFile: AVAudioFile = session.track.playbackInfo?.audioFile,
            let totalFrames: AVAudioFramePosition = session.track.playbackInfo?.frames {

            let sampleRate = playingFile.processingFormat.sampleRate

            //  Multiply sample rate by the new seek time in seconds. This will produce the exact start frame.
            var firstFrame = AVAudioFramePosition(startTime * sampleRate)
            var lastFrame: AVAudioFramePosition
            var segmentEndTime: Double

            // Check if a complete loop is present.
            if let _endTime = endTime {

                // Use loop end time to calculate the last frame.
                lastFrame = AVAudioFramePosition(_endTime * sampleRate)
                segmentEndTime = _endTime

            } else {

                // No loop, use audio file's total frame count
                lastFrame = totalFrames
                segmentEndTime = session.track.duration
            }

            var frameCount: AVAudioFrameCount = AVAudioFrameCount(lastFrame - firstFrame + 1)

            // If the frame count is less than the minimum required to continue playback,
            // schedule the minimum frame count for playback, to avoid scheduling problems
            if frameCount < 1 {

                frameCount = 1
                firstFrame = lastFrame
            }
            
            return PlaybackSegment(session, playingFile, firstFrame, lastFrame, frameCount, startTime, segmentEndTime)
        }

        // Impossible
        return nil
    }

    func segmentCompleted(_ session: PlaybackSession) {
        
        // If the segment-associated session is not the same as the current session
        // (possible if stop() was called, eg. when seeking), don't do anything
        if PlaybackSession.isCurrent(session) {
            
            // Prevent lastSeekPosn from overruning the track duration to prevent weird incorrect UI displays of seek time
            lastSeekPosn = session.track.duration
            
            if playerNode.isPlaying {
                trackCompleted()
                
            } else {
                completedWhilePaused = true
            }
        }
    }
    
    // Signal track playback completion
    private func trackCompleted() {
        AsyncMessenger.publishMessage(PlaybackCompletedAsyncMessage.instance)
    }

    func pause() {

        // Update lastSeekPosn before pausing
        _ = seekPosition
        playerNode.pause()
    }

    func resume() {
        
        if completedWhilePaused {

            completedWhilePaused = false
            trackCompleted()
            
        } else {
            playerNode.play()
        }
    }

    // Clears any previously scheduled segments and stops playback, in response to a request to stop playback, change a track, or when seeking to a new position. Marks the end of a "playback session".
    func stop() {

        playerNode.stop()
        completedWhilePaused = false
    }

    // Retrieves the current seek position, in seconds
    var seekPosition: Double {

        if let nodeTime = playerNode.lastRenderTime, let playerTime = playerNode.playerTime(forNodeTime: nodeTime) {

            lastSeekPosn = Double(startFrame + playerTime.sampleTime) / playerTime.sampleRate

            // Prevent lastSeekPosn from overruning the track duration (or loop start/end times)
            // to prevent weird incorrect UI displays of seek time
            if let session = PlaybackSession.currentSession {
                
                // Check for complete loop
                if let loop = session.loop, let loopEndTime = loop.endTime {
                    
                    lastSeekPosn = min(max(loop.startTime, lastSeekPosn), loopEndTime)
                    
                } else {
                    lastSeekPosn = min(max(0, lastSeekPosn), session.track.duration)
                }
            }
        }

        // Default to last remembered position when nodeTime is nil
        return lastSeekPosn
    }

    // MARK: Loop scheduling -------------------------------------------------------------------------------------------
    
    // Starts loop playback at the beginning of the loop
    func playLoop(_ session: PlaybackSession, _ beginPlayback: Bool) {
        
        if let loop = session.loop {
            playLoop(session, loop.startTime, beginPlayback)
        }
    }

    // Starts loop playback but not necessarily at the beginning of the loop (e.g. chapter loop)
    func playLoop(_ session: PlaybackSession, _ startTime: Double, _ beginPlayback: Bool) {

        stop()

        if let loop = session.loop, let loopEndTime = loop.endTime {

            // Define the initial segment (which may not constitute the entire portion of the loop segment)
            let segment = scheduleSegment(session, .dataPlayedBack, {(callbackType: AVAudioPlayerNodeCompletionCallbackType) -> Void in

              DispatchQueue.global(qos: .userInteractive).async {self.loopSegmentCompleted(session)}

            }, true, startTime, loopEndTime)
            
            self.loopingSegment = loop.startTime == startTime ? segment : nil
        }

        // Don't start playing if player is paused
        if beginPlayback {
            playerNode.play()
        }
    }

    func loopSegmentCompleted(_ session: PlaybackSession) {

        // Validate the session and check for a complete loop
        if PlaybackSession.isCurrent(session),
            let loop = session.loop, let loopEndTime = loop.endTime {

            let wasPlaying: Bool = playerNode.isPlaying
            stop()

            // The very first time (i.e. the first restart of the loop), this may be nil, so compute it.
            if self.loopingSegment == nil {
                self.loopingSegment = computeSegment(session, loop.startTime, loopEndTime)
            }

            if let loopSegment = self.loopingSegment {

                // Reschedule the looping segment
                doScheduleSegment(loopSegment, .dataPlayedBack, {(callbackType: AVAudioPlayerNodeCompletionCallbackType) -> Void in
                    
                    DispatchQueue.global(qos: .userInteractive).async {self.loopSegmentCompleted(session)}
                    
                }, true)

                if wasPlaying {
                    playerNode.play()
                }
            }
        }
    }
    
    func endLoop(_ session: PlaybackSession, _ loopEndTime: Double) {
        
        // Schedule a new segment starting from the loop's end time, up to the end of the track.
        
        _ = scheduleSegment(session, .dataPlayedBack, {(callbackType: AVAudioPlayerNodeCompletionCallbackType) -> Void in
            
            DispatchQueue.global(qos: .userInteractive).async {self.segmentCompleted(session)}

        }, false, loopEndTime)  // false parameter value indicates this segment is not for immediate playback
        
        // Invalidate the previously defined loop segment
        self.loopingSegment = nil
    }
}
