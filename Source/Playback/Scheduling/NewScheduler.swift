import Cocoa
import AVFoundation

/*
    Manages audio scheduling, and playback. See PlaybackSchedulerProtocol for more details on all the functions provided.
 */
@available(OSX 10.13, *)
class NewScheduler: PlaybackSchedulerProtocol {
    
    // Interval (defined in seconds) used for scheduling of a minimal playback segment to prevent problems arising from zero/negative frame counts and to ensure
    // that the completion handler is invoked (eg. at the end of a track)
    static let minPlaybackTime: Double = 0.01

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
        
        print("Seek to time:", session.id, startTime, beginPlayback)

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
    
    // TODO: How to deal with 0 frame segments when paused ?
    // 1 - Schedule a few frames (downside is seek position will go back ... noticeable for very short 5 second tracks)
    // OR
    // 2 - Set the flag completedWhilePaused ... if so, where should it be set ... in seekToTime ???

    private func computeSegment(_ session: PlaybackSession, _ startTime: Double, _ endTime: Double? = nil) -> PlaybackSegment? {

        if let playingFile: AVAudioFile = session.track.playbackInfo?.audioFile,
            let totalFrames: AVAudioFramePosition = session.track.playbackInfo?.frames {

            let sampleRate = playingFile.processingFormat.sampleRate
//            let minFrames = AVAudioFrameCount(sampleRate * NewScheduler.minPlaybackTime)
            let minFrames = AVAudioFrameCount(1)

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
            
            // TODO: Can we just return nil and let the caller decide how to proceed ???
            if frameCount < minFrames {

                frameCount = minFrames
                firstFrame = AVAudioFramePosition(AVAudioFrameCount(lastFrame) - minFrames + 1)
                
//                frameCount = 2500
//                firstFrame = AVAudioFramePosition(AVAudioFrameCount(lastFrame) - frameCount + 1)
                
                print("Scheduling frames:", frameCount)
            }
            
            return PlaybackSegment(session, playingFile, firstFrame, lastFrame, frameCount, startTime, segmentEndTime)
        }

        // Impossible
        return nil
    }

    private func segmentCompleted(_ session: PlaybackSession) {
        
        // TODO: Make sure that once a session has completed (i.e. async message sent out), no other segment can be associated with that session.
        // Otherwise, the same session can complete twice.
        
        // If the segment-associated session is not the same as the current session
        // (possible if stop() was called, eg. when seeking), don't do anything
        if let curSession = PlaybackSession.currentSession, curSession == session {
            
            print("Completion:", session.id)

            // Prevent lastSeekPosn from overruning the track duration to prevent weird incorrect UI displays of seek time
            lastSeekPosn = session.track.duration
            
            if playerNode.isPlaying {
                
                // Signal track playback completion
                AsyncMessenger.publishMessage(PlaybackCompletedAsyncMessage.instance)
                
            } else {
                
                print("Completed while paused")
                completedWhilePaused = true
            }
        }
    }

    func pause() {

        // Update lastSeekPosn before pausing
        _ = seekPosition
        playerNode.pause()
    }

    func resume() {
        
        if completedWhilePaused {

            completedWhilePaused = false
            AsyncMessenger.publishMessage(PlaybackCompletedAsyncMessage.instance)
            
        } else {
            playerNode.play()
        }
    }

    // Clears any previously scheduled segments and stops playback, in response to a request to stop playback, change a track, or when seeking to a new position. Marks the end of a "playback session".
    func stop() {

        // Clear any previous buffers and stop playback
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

              DispatchQueue.global(qos: .userInteractive).async {self.restartLoop(session)}

            }, true, startTime, loopEndTime)
            
            // TODO: If segment is nil, can we start at loop start time ???

            self.loopingSegment = loop.startTime == startTime ? segment : nil
        }

        // Don't start playing if player is paused
        if beginPlayback {
            playerNode.play()
        }
    }

    private func restartLoop(_ session: PlaybackSession) {

        // Validate the session and check for a complete loop
        if let curSession = PlaybackSession.currentSession, curSession == session,
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
                    
                    DispatchQueue.global(qos: .userInteractive).async {self.restartLoop(session)}
                    
                }, true)

                if wasPlaying {
                    playerNode.play()
                }
            }
        }
    }
    
    func endLoop(_ session: PlaybackSession, _ loopEndTime: Double) {
        
        // Schedule a new segment starting from the loop's end time, up to the end of the track.
        
        // TODO: Check if the loop is terminal (loopEndTime == trackDuration) ... if so, schedule a token segment for track completion.

        _ = scheduleSegment(session, .dataPlayedBack, {(callbackType: AVAudioPlayerNodeCompletionCallbackType) -> Void in
            
            DispatchQueue.global(qos: .userInteractive).async {self.segmentCompleted(session)}

        }, false, loopEndTime)  // false parameter value indicates this segment is not for immediate playback
        
        // Invalidate the previously defined loop segment
        self.loopingSegment = nil
    }
}

// Encapsulates all data required to schedule one audio file segment for playback. Can be passed around between functions and can be cached for reuse (when playing a segment loop).
struct PlaybackSegment {

    let session: PlaybackSession

    let playingFile: AVAudioFile

    let startTime: Double
    let endTime: Double?

    let firstFrame: AVAudioFramePosition
    let lastFrame: AVAudioFramePosition

    let frameCount: AVAudioFrameCount

    init(_ session: PlaybackSession, _ playingFile: AVAudioFile, _ firstFrame: AVAudioFramePosition, _ lastFrame: AVAudioFramePosition, _ frameCount: AVAudioFrameCount, _ startTime: Double, _ endTime: Double? = nil) {

        self.session = session
        self.playingFile = playingFile

        self.startTime = startTime
        self.endTime = endTime

        self.firstFrame = firstFrame
        self.lastFrame = lastFrame

        self.frameCount = frameCount
    }
}

// ------------------------------- TODO: Logic for calculating seek position during gapless loop playback -------------------------------

////            var samplesPlayed: AVAudioFramePosition = playerTime.sampleTime
//
//            lastSeekPosn = Double(startFrame + playerTime.sampleTime) / playerTime.sampleRate
//
//            // ********** USE FIRST FRAME, LAST FRAME, AND FRAME COUNT IN LOOPING SEGMENT TO CALCULATE POSITION WHEN LOOPING ********
//
//            // Prevent lastSeekPosn from overruning the track duration to prevent weird incorrect UI displays of seek time
//            if let session = PlaybackSession.currentSession {
//
//                // Check for complete loop
//                //                if let loopEndTime = session.loop?.endTime, let loopSegment = self.loopingSegment {
////                if let loopSegment = self.loopingSegment, let loopEndTime = loopSegment.endTime  {
////
//////                    print("\nSeekPos:", lastSeekPosn)
//////                    print("StartFrame:", startFrame!,
//////                          "SampleTime:", playerTime.sampleTime, "SampleRate:", playerTime.sampleRate)
////
////                    if samplesPlayed > loopSegment.frameCount {
////
////                        samplesPlayed = samplesPlayed % Int64(loopSegment.frameCount)
////                        lastSeekPosn = Double(loopSegment.firstFrame + samplesPlayed) / playerTime.sampleRate
////                        lastSeekPosn = min(lastSeekPosn, loopEndTime)
////
//////                        print("NOW SeekPos:", lastSeekPosn)
////                    }
////
////                } else {
//                    lastSeekPosn = min(max(0, lastSeekPosn), session.track.duration)
////                }
//            }
//        }
