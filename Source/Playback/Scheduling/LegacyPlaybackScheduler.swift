import Cocoa
import AVFoundation

/*
    Manages audio scheduling, and playback. See PlaybackSchedulerProtocol for more details on all the functions provided.
 */
class LegacyPlaybackScheduler: PlaybackSchedulerProtocol {

    // Player node used for actual playback
    private var playerNode: AVAudioPlayerNode

    // The start frame for the current playback session (used to calculate seek position). Represents the point in the track at which playback began.
    private var startFrame: AVAudioFramePosition = 0

    // Cached seek position (used when looping, to remember last seek position and avoid displaying 0 when player is temporarily stopped at the end of a loop)
    private var lastSeekPosn: Double = 0
    
    // Indicates whether or not a track completed while the player was paused.
    // This is required because, in rare cases, some file segments may complete when they've reached close to the end, even if the last frame has not played yet.
    private var trackCompletedWhilePaused: Bool = false

    // Caches a previously computed/scheduled playback segment, when a segment loop is defined, in order to prevent redundant computations.
    private var loopingSegment: PlaybackSegment?
    
    // The absolute minimum frame count when scheduling a segment (to prevent crashes in the playerNode).
    static let minFrames: AVAudioFrameCount = 2
    
    // A timer used to check if track playback has completed. This is required because the playerNode sends completion notifications prematurely, before track
    // playback has been completed. This problem has been fixed in PlaybackScheduler. It is the reason why this class is now deprecated, and only in use on macOS Sierra
    // systems.
    private var completionPollTimer: RepeatingTaskExecutor?
    
    // The interval at which the completionPollTimer repeats its task.
    static let completionPollTimerIntervalMillis: Int = 125     // 1/8th of a second
    
    // Interval used for comparing two Double values (to avoid problems with Double precision resulting in equal values being considered inequal)
    // If two Double track seek times are within 0.01 seconds of each other, we'll consider them equal (used to detect the completion of playback of a loop or segment)
    static let timeComparisonTolerance: Double = 0.01

    init(_ playerNode: AVAudioPlayerNode) {
        self.playerNode = playerNode
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
    
    // MARK: Track playback and seeking functions -------------------------------------------------------------------------------------------
    
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

        // Halt current playback
        stop()

        _ = scheduleSegment(session, segmentCompletionHandler(session), true, startTime)

        // Don't start playing if player is paused
        if beginPlayback {
            playerNode.play()
        }
    }
    
    func pause() {

        // Update lastSeekPosn before pausing
        _ = seekPosition
        playerNode.pause()
        
        // If the completion timer is running, pause it
        completionPollTimer?.pause()
    }

    func resume() {
        
        playerNode.play()
        
        // If the completion timer is paused, resume it
        completionPollTimer?.startOrResume()
    }

    // Clears any previously scheduled segments and stops playback, in response to a request to stop playback, change a track, or when seeking to a new position. Marks the end of a "playback session".
    func stop() {

        playerNode.stop()
        trackCompletedWhilePaused = false
        
        // Completion timer is no longer relevant for this playback session which has ended. The next session will spawn a new timer if/when needed.
        destroyCompletionTimer()
    }
    
    // MARK: Loop scheduling functions -------------------------------------------------------------------------------------------
    
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
            let segment = scheduleSegment(session, loopCompletionHandler(session), true, startTime, loopEndTime)
            
            // If this segment constitutes the entire loop segment, cache it for reuse later when restarting the loop.
            self.loopingSegment = loop.startTime == startTime ? segment : nil
            
            // Don't start playing if player is paused
            if beginPlayback {
                playerNode.play()
            }
        }
    }

    func endLoop(_ session: PlaybackSession, _ loopEndTime: Double) {
        
        destroyCompletionTimer()
        
        var newSegmentStartFrame: AVAudioFramePosition? = nil
        
        // If a cached loop segment is present, use it to compute an exact start frame for the new segment.
        if let loopSegment = self.loopingSegment {
            
            newSegmentStartFrame = loopSegment.lastFrame + 1
            self.loopingSegment = nil
        }
        
        // Schedule a new segment starting from the loop's end time, up to the end of the track.
        
        // false parameter value indicates this segment is not for immediate playback.
        // nil parameter indicates no specific end time (i.e. end of track is implied).
        _ = scheduleSegment(session, segmentCompletionHandler(session), false, loopEndTime, nil, newSegmentStartFrame)
    }
    
    // MARK: Completion handler functions -------------------------------------------------------

    func segmentCompleted(_ session: PlaybackSession) {
        
        // If the segment-associated session is not the same as the current session
        // (possible if stop() was called, eg. old segments that complete when seeking), don't do anything
        if PlaybackSession.isCurrent(session) {
            
            // Start the completion poll timer
            completionPollTimer = RepeatingTaskExecutor(intervalMillis: LegacyPlaybackScheduler.completionPollTimerIntervalMillis, task: {
                
                self.pollForTrackCompletion()
                
            }, queue: DispatchQueue.global(qos: .userInteractive))
            
            // Don't start the timer if player is paused
            if playerNode.isPlaying {
                completionPollTimer?.startOrResume()
            }
            
        } else {
            destroyCompletionTimer()
        }
    }
    
    private func pollForTrackCompletion() {
        
        if let trackDuration = PlaybackSession.currentSession?.track.duration {
            
            // This will update lastSeekPosn
            _ = seekPosition
            
            if lastSeekPosn > (trackDuration - LegacyPlaybackScheduler.timeComparisonTolerance) {
                
                // Prevent lastSeekPosn from overruning the track duration to prevent weird incorrect UI displays of seek time
                lastSeekPosn = trackDuration
                
                // Notify observers that the track has finished playing. Don't do this if paused and seeking to the end.
                if playerNode.isPlaying {

                    trackCompleted()
                    destroyCompletionTimer()
                }
            }
            
        } else {
            destroyCompletionTimer()
        }
    }
    
    // Signal track playback completion
    private func trackCompleted() {
        AsyncMessenger.publishMessage(PlaybackCompletedAsyncMessage.instance)
    }
    
    func loopSegmentCompleted(_ session: PlaybackSession) {

        // Validate the session and check for a complete loop
        if PlaybackSession.isCurrent(session), session.hasCompleteLoop() {
            
            // Start the completion poll timer
            completionPollTimer = RepeatingTaskExecutor(intervalMillis: LegacyPlaybackScheduler.completionPollTimerIntervalMillis, task: {
                
                self.pollForLoopCompletion()
                
            }, queue: DispatchQueue.global(qos: .userInteractive))
            
            // Don't start the timer if player is paused
            if playerNode.isPlaying {
                completionPollTimer?.startOrResume()
            }
            
        } else {
            destroyCompletionTimer()
        }
    }
    
    private func pollForLoopCompletion() {
        
        if let session = PlaybackSession.currentSession, let loop = session.loop, let loopEndTime = loop.endTime {
            
            // This will update lastSeekPosn
            _ = seekPosition
            
            if lastSeekPosn > (loopEndTime - LegacyPlaybackScheduler.timeComparisonTolerance) {
                
                lastSeekPosn = loopEndTime
                
                if playerNode.isPlaying {
                    
                    destroyCompletionTimer()
                    restartLoop(session, loop.startTime, loopEndTime)
                }
            }
            
        } else {
            destroyCompletionTimer()
        }
    }
    
    private func restartLoop(_ session: PlaybackSession, _ startTime: Double, _ endTime: Double) {
        
        let wasPlaying: Bool = playerNode.isPlaying
        stop()

        // Check if a loop segment was cached previously.
        // The very first time (i.e. the first restart of the loop), this may be nil, so compute it.
        if self.loopingSegment == nil {
            self.loopingSegment = computeSegment(session, startTime, endTime)
        }

        // Use the cached/compute segment to schedule another loop iteration.
        if let loopSegment = self.loopingSegment {

            // Reschedule the looping segment
            doScheduleSegment(loopSegment, loopCompletionHandler(session), true)

            if wasPlaying {
                playerNode.play()
            }
        }
    }
    
    private func destroyCompletionTimer() {
        
        completionPollTimer?.stop()
        completionPollTimer = nil
    }

    // Computes a segment completion handler closure, given a playback session.
    private func segmentCompletionHandler(_ session: PlaybackSession) -> AVAudioNodeCompletionHandler {
        
        return {DispatchQueue.global(qos: .userInteractive).async {self.segmentCompleted(session)}}
    }
    
    // Computes a loop segment completion handler closure, given a playback session.
    private func loopCompletionHandler(_ session: PlaybackSession) -> AVAudioNodeCompletionHandler {
        
        return {DispatchQueue.global(qos: .userInteractive).async {self.loopSegmentCompleted(session)}}
    }
    
    // MARK: Segment computation and scheduling functions -------------------------------------------------------

    private func scheduleSegment(_ session: PlaybackSession, _ completionHandler: AVAudioNodeCompletionHandler?, _ immediatePlayback: Bool, _ startTime: Double, _ endTime: Double? = nil, _ startFrame: AVAudioFramePosition? = nil) -> PlaybackSegment? {

        if let segment = computeSegment(session, startTime, endTime, startFrame) {

            doScheduleSegment(segment, completionHandler, immediatePlayback)
            return segment
        }

        return nil
    }

    private func doScheduleSegment(_ segment: PlaybackSegment, _ completionHandler: AVAudioNodeCompletionHandler?, _ immediatePlayback: Bool) {

        // The start frame and seek position should be reset only if this segment will be played immediately.
        // If it is being scheduled for the future, doing this will cause inaccurate seek position values.
        if immediatePlayback {
            
            // Advance the last seek position to the new position
            startFrame = segment.firstFrame
            lastSeekPosn = segment.startTime
        }

        // Schedule a segment beginning at the seek time, with the calculated frame count reflecting the remaining audio frames in the file
        playerNode.scheduleSegment(segment.playingFile, startingFrame: segment.firstFrame, frameCount: segment.frameCount, at: nil, completionHandler: completionHandler)
    }

    private func computeSegment(_ session: PlaybackSession, _ startTime: Double, _ endTime: Double? = nil, _ startFrame: AVAudioFramePosition? = nil) -> PlaybackSegment? {

        if let playbackInfo = session.track.playbackInfo, let playingFile: AVAudioFile = playbackInfo.audioFile {

            let sampleRate = playbackInfo.sampleRate

            // If an exact start frame is specified, use it.
            // Otherwise, multiply sample rate by the new seek time in seconds to obtain the start frame.
            var firstFrame: AVAudioFramePosition = startFrame ?? AVAudioFramePosition(startTime * sampleRate)
            
            var lastFrame: AVAudioFramePosition
            var segmentEndTime: Double

            // Check if a complete loop is present.
            if let loopEndTime = endTime {

                // Use loop end time to calculate the last frame.
                lastFrame = AVAudioFramePosition(loopEndTime * sampleRate)
                segmentEndTime = loopEndTime

            } else {

                // No loop, use audio file's total frame count
                lastFrame = playbackInfo.frames
                segmentEndTime = session.track.duration
            }

            var frameCount: AVAudioFrameCount = AVAudioFrameCount(lastFrame - firstFrame + 1)

            // If the frame count is less than the minimum required to continue playback,
            // schedule the minimum frame count for playback, to avoid crashes in the playerNode.
            if frameCount < LegacyPlaybackScheduler.minFrames {
                
                frameCount = LegacyPlaybackScheduler.minFrames
                firstFrame = lastFrame - AVAudioFramePosition(frameCount) + 1
            }
            
            return PlaybackSegment(session, playingFile, firstFrame, lastFrame, frameCount, startTime, segmentEndTime)
        }

        // Impossible
        return nil
    }
}
