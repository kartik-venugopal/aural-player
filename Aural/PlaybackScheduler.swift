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
    
    init(_ playerNode: AVAudioPlayerNode) {
        self.playerNode = playerNode
    }
    
    // Start track playback from the beginning
    func playTrack(_ playbackSession: PlaybackSession) {
        doPlayTrack(playbackSession)
    }
    
    // Start track playback from a given position expressed in seconds
    func playTrack(_ playbackSession: PlaybackSession, _ startPosition: Double) {
        doPlayTrack(playbackSession, startPosition)
    }
    
    // Starts track playback from a given frame position. The playbackSesssion parameter is used to ensure that no buffers are scheduled on the player for an old playback session.
    private func doPlayTrack(_ playbackSession: PlaybackSession, _ startPosition: Double? = nil) {
        
        if let startPosn = startPosition {
            
            seekToTime(playbackSession, startPosn, true)
            return
        }
        
        // This means startPosition is 0
        startFrame = PlaybackScheduler.FRAME_ZERO
        lastSeekPosn = 0
        
        // Can assume that audioFile is non-nil, because track has been prepared for playback
        let playingFile: AVAudioFile = playbackSession.track.playbackInfo!.audioFile!
        
        playerNode.scheduleFile(playingFile, at: nil, completionHandler: nil)
        playerNode.play()
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
        playerNode.scheduleSegment(playingFile, startingFrame: firstFrame, frameCount: AVAudioFrameCount(frameCount), at: nil, completionHandler: nil)
        
        // Don't start playing if player is paused
        if beginPlayback {
            playerNode.play()
        }
    }
    
    // The A->B loop has been removed. Need to resume normal playback till the end of the track.
    func endLoop(_ playbackSession: PlaybackSession, _ loopEndTime: Double) {
        
        // Schedule a new segment from loopEnd -> trackEnd
        
        // Can assume that playbackInfo is non-nil, because track has been prepared for playback
        let playbackInfo: PlaybackInfo = playbackSession.track.playbackInfo!
        let playingFile: AVAudioFile = playbackInfo.audioFile!
        let sampleRate = playbackSession.track.playbackInfo!.sampleRate!
        
        //  Multiply sample rate by the seek time in seconds. This will produce the exact start and end frames.
        let firstFrame = Int64(loopEndTime * sampleRate) + 1
        let frameCount = playbackInfo.frames! - firstFrame + 1
        
        // Schedule a segment beginning at the seek time, with the calculated frame count reflecting the remaining audio frames in the file
        playerNode.scheduleSegment(playingFile, startingFrame: firstFrame, frameCount: AVAudioFrameCount(frameCount), at: nil, completionHandler: nil)
        
        NSLog("Scheduled the finishing segment starting at: %f lasting %f", loopEndTime, Double(frameCount)/sampleRate)
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
        
        if playbackSession.hasCompleteLoop() {
            
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
        playerNode.scheduleSegment(playingFile, startingFrame: firstFrame, frameCount: AVAudioFrameCount(frameCount), at: nil, completionHandler: nil)
        
        // Don't start playing if player is paused
        if beginPlayback {
            playerNode.play()
        }
    }
    
    func pause() {
        
        // Update lastSeekPosn before pausing
        _ = getSeekPosition()
        playerNode.pause()
    }
    
    func resume() {
        playerNode.play()
    }
    
    // Stops the scheduling of audio buffers, in response to a request to stop playback (or when seeking to a new position). Marks the end of a "playback session".
    func stop() {
        playerNode.stop()
    }
    
    // Retrieves the current seek position, in seconds
    func getSeekPosition() -> Double {
        
        if let nodeTime = playerNode.lastRenderTime {
            
            if let playerTime = playerNode.playerTime(forNodeTime: nodeTime) {
                lastSeekPosn = Double(startFrame! + playerTime.sampleTime) / playerTime.sampleRate
            }
        }
        
        // TODO: When playback rate is slow (e.g. 0.25 x), there will be a 2 seconds dead time at the end, before playback completes. Maybe need a separate timer after all
        // Detect track playback completion
        if let session = PlaybackSession.currentSession {
            
            if session.hasCompleteLoop() {
                
                let loop = session.loop!
                let endTime = loop.endTime!
                
                if lastSeekPosn >= endTime {
                    
                    lastSeekPosn = endTime
                    
                    playLoop(session, playerNode.isPlaying)
                }
                
            } else {
                
                let duration = session.track.duration
                
                if lastSeekPosn >= duration {
                    
                    // Prevent lastSeekPosn from overruning the track duration to prevent weird incorrect UI displays of seek time
                    lastSeekPosn = duration
                    
                    // Don't do this if paused and seeking to the end
                    if (playerNode.isPlaying) {
                        trackPlaybackCompleted(session)
                    }
                }
            }
        }
        
        // Default to last remembered position when nodeTime is nil
        return lastSeekPosn
    }
    
    private func trackPlaybackCompleted(_ session: PlaybackSession) {
        AsyncMessenger.publishMessage(PlaybackCompletedAsyncMessage.instance)
    }
}
