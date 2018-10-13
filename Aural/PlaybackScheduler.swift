import Foundation
import AVFoundation

/*
    Manages audio scheduling, and playback. Provides two main operations - play() and seekToTime(). Works in conjunction with a playerNode to perform playback.
 
 A "playback session" begins when playback is started, as a result of either play() or seekToTime(). It ends when either playback is completed or a new request is received (and stop() is called).
 */
class PlaybackScheduler {
    
    // Indicates the beginning of a file, used when starting file playback
    static let FRAME_ZERO = AVAudioFramePosition(0)
    
    // Player node used for actual playback
    private var playerNode: AVAudioPlayerNode
    
    // The start frame for the current playback session (used to calculate seek position). Represents the point in the track at which playback began.
    private var startFrame: AVAudioFramePosition?
    
    // Cached seek position (used when looping, to remember last seek position and avoid displaying 0 when player is temporarily stopped at the end of a loop)
    private var lastSeekPosn: Double = 0
    
    private var completionPollTimer: RepeatingTaskExecutor?
    
    private var lastCompletedSession: PlaybackSession?
    
    private var playerStopped: Bool = false
    
    init(_ playerNode: AVAudioPlayerNode) {
        self.playerNode = playerNode
    }
    
    // Start track playback from a given position expressed in seconds
    func playTrack(_ playbackSession: PlaybackSession, _ startPosition: Double) {
        doPlayTrack(playbackSession, startPosition)
    }
    
    // Starts track playback from a given frame position. The playbackSesssion parameter is used to ensure that no buffers are scheduled on the player for an old playback session.
    private func doPlayTrack(_ playbackSession: PlaybackSession, _ startPosition: Double) {
        seekToTime(playbackSession, startPosition, true)
    }
    
    func playLoop(_ playbackSession: PlaybackSession, _ beginPlayback: Bool = true) {
        
        // Halt current playback
        stop()
        
        // Can assume that playbackInfo is non-nil, because track has been prepared for playback
        let playbackInfo: PlaybackInfo = playbackSession.track.playbackInfo!
        let playingFile: AVAudioFile = playbackInfo.audioFile!
        let sampleRate = playbackSession.track.playbackInfo!.sampleRate!
        
        // Can assume loop is non-null and complete (Player will take care of that)
        let loop = playbackSession.loop!
        
        //  Multiply sample rate by the seek time in seconds. This will produce the exact start and end frames.
        let firstFrame = Int64(loop.startTime * sampleRate)
        let lastFrame = Int64(loop.endTime! * sampleRate)
        let frameCount = lastFrame - firstFrame + 1
        
        // Advance the last seek position to the new position
        startFrame = firstFrame
        lastSeekPosn = loop.startTime
        
        // Schedule a segment beginning at the seek time, with the calculated frame count reflecting the remaining audio frames in the file
        playerNode.scheduleSegment(playingFile, startingFrame: firstFrame, frameCount: AVAudioFrameCount(frameCount), at: nil, completionHandler: {
            self.loopCompleted(playbackSession)
        })
        
        // Don't start playing if player is paused
        if beginPlayback {
            playerNode.play()
        }
    }
    
    // The A->B loop has been removed. Need to resume normal playback till the end of the track.
    func endLoop(_ playbackSession: PlaybackSession, _ loopEndTime: Double) {
        
        // Schedule a new segment from loopEnd -> trackEnd
        completionPollTimer?.stop()
        
        // Can assume that playbackInfo is non-nil, because track has been prepared for playback
        let playbackInfo: PlaybackInfo = playbackSession.track.playbackInfo!
        let playingFile: AVAudioFile = playbackInfo.audioFile!
        let sampleRate = playbackSession.track.playbackInfo!.sampleRate!
        
        //  Multiply sample rate by the seek time in seconds. This will produce the exact start and end frames.
        let firstFrame = Int64(loopEndTime * sampleRate) + 1
        let frameCount = playbackInfo.frames! - firstFrame + 1
        
        // Schedule a segment beginning at the seek time, with the calculated frame count reflecting the remaining audio frames in the file
        playerNode.scheduleSegment(playingFile, startingFrame: firstFrame, frameCount: AVAudioFrameCount(frameCount), at: nil, completionHandler: {
            self.segmentCompleted(playbackSession)
        })
    }
    
    // Seeks to a certain position (seconds) in the specified track. Returns the calculated start frame.
    func seekToTime(_ playbackSession: PlaybackSession, _ seconds: Double, _ beginPlayback: Bool) {
        
        // Halt current playback
        stop()
        
        // Can assume that playbackInfo is non-nil, because track has been prepared for playback
        let playbackInfo: PlaybackInfo = playbackSession.track.playbackInfo!
        let playingFile: AVAudioFile = playbackInfo.audioFile!
        let sampleRate = playbackSession.track.playbackInfo!.sampleRate!
        
        //  Multiply sample rate by the new seek time in seconds. This will produce the exact start frame.
        let firstFrame = Int64(seconds * sampleRate)
        var lastFrame: Int64 = 0
        
        var hasLoop: Bool = false
        
        if playbackSession.hasCompleteLoop() {
            
            hasLoop = true
            
            let loop = playbackSession.loop!
            lastFrame = Int64(loop.endTime! * sampleRate)
            
        } else {
            
            lastFrame = playbackInfo.frames!
        }
        
        let frameCount = lastFrame - firstFrame + 1
        
        // Advance the last seek position to the new position
        startFrame = firstFrame
        lastSeekPosn = seconds
        
        // Schedule a segment beginning at the seek time, with the calculated frame count reflecting the remaining audio frames in the file
        playerNode.scheduleSegment(playingFile, startingFrame: firstFrame, frameCount: AVAudioFrameCount(frameCount), at: nil, completionHandler: {
            hasLoop ? self.loopCompleted(playbackSession) : self.segmentCompleted(playbackSession)
        })
        
        // Don't start playing if player is paused
        if beginPlayback {
            playerNode.play()
        }
    }
    
    private func segmentCompleted(_ session: PlaybackSession) {
        
        if self.playerStopped {
            // Player queue is being flushed (e.g. when seeking) ... ignore this event
            return
        }
        
        // Start the completion poll timer
        completionPollTimer = RepeatingTaskExecutor(intervalMillis: 125, task: {
            
            self.pollForTrackCompletion()
            
        }, queue: DispatchQueue.global(qos: .userInteractive))
        
        // Don't start the timer if player is paused
        if playerNode.isPlaying {
            completionPollTimer?.startOrResume()
        }
    }
    
    private func pollForTrackCompletion() {
        
        if let session = PlaybackSession.currentSession {
            
            let duration = session.track.duration
            
            if lastSeekPosn >= duration {
                
                // Prevent lastSeekPosn from overruning the track duration to prevent weird incorrect UI displays of seek time
                lastSeekPosn = duration
                
                // Notify observers that the track has finished playing. Don't do this if paused and seeking to the end.
                if (playerNode.isPlaying && session !== lastCompletedSession) {
                    
                    trackPlaybackCompleted(session)
                    lastCompletedSession = session
                    
                    completionPollTimer?.stop()
                }
            }
            
        } else {
            // Theoretically impossible
            completionPollTimer?.stop()
        }
    }
    
    private func loopCompleted(_ session: PlaybackSession) {
        
        if self.playerStopped {
            // TODO: Will this always work ??? What if stopping the player after a seek close to the end of the track takes a long time, past the end of the track ?
            // Player queue is being flushed (e.g. when seeking) ... ignore this event
            return
        }
        
        // Start the completion poll timer
        completionPollTimer = RepeatingTaskExecutor(intervalMillis: 125, task: {
            
            self.pollForLoopCompletion()
            
        }, queue: DispatchQueue.global(qos: .userInteractive))
        
        // Don't start the timer if player is paused
        if playerNode.isPlaying {
            completionPollTimer?.startOrResume()
        }
    }
    
    private func pollForLoopCompletion() {
        
        if let session = PlaybackSession.currentSession, session.hasCompleteLoop() {
            
            let loopEndTime = session.loop!.endTime!
            
            if lastSeekPosn >= loopEndTime {
                
                lastSeekPosn = loopEndTime
                
                if playerNode.isPlaying {
                    // Restart loop
                    playLoop(session, true)
                }
            }
            
        } else {
            // Theoretically impossible (no current session)
            completionPollTimer?.stop()
        }
    }
    
    func pause() {
        
        // Update lastSeekPosn before pausing
        _ = getSeekPosition()
        playerNode.pause()
        
        // If the completion timer is running, pause it
        completionPollTimer?.pause()
    }
    
    func resume() {
        
        playerNode.play()
        
        // If the completion timer is paused, resume it
        completionPollTimer?.startOrResume()
    }
    
    // Stops the scheduling of audio buffers, in response to a request to stop playback (or when seeking to a new position). Marks the end of a "playback session".
    func stop() {
        
        playerStopped = true
        playerNode.stop()
        playerStopped = false
        
        // Completion timer is no longer relevant for this playback session which has ended. The next session will spawn a new timer if/when needed.
        completionPollTimer?.stop()
    }
    
    // Retrieves the current seek position, in seconds
    func getSeekPosition() -> Double {
        
        if let nodeTime = playerNode.lastRenderTime, let playerTime = playerNode.playerTime(forNodeTime: nodeTime) {
            lastSeekPosn = Double(startFrame! + playerTime.sampleTime) / playerTime.sampleRate
        }
        
        // Default to last remembered position when nodeTime is nil
        return lastSeekPosn
    }
    
    private func trackPlaybackCompleted(_ session: PlaybackSession) {
        AsyncMessenger.publishMessage(PlaybackCompletedAsyncMessage.instance)
    }
}
