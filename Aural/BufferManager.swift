import Cocoa
import AVFoundation

/*
    Manages audio buffer allocation, scheduling, and playback. Provides two main operations - play() and seekToTime(). Works in conjunction with a playerNode to perform playback.

    A "playback session" begins when playback is started, as a result of either play() or seekToTime(). It ends when either playback is completed or a new request is received (and stop() is called).
*/
class BufferManager {
    
    // Indicates the beginning of a file, used when starting file playback
    static let FRAME_ZERO = AVAudioFramePosition(0)
    
    // Seconds of playback
    private static let BUFFER_SIZE: UInt32 = 15
    
    // The very first buffer should be small, so as to facilitate efficient immediate playback
    private static let BUFFER_SIZE_INITIAL: UInt32 = 5
    
    // The (serial) dispatch queue on which all scheduling tasks will be enqueued
    private var queue: OperationQueue
    
    // Player node used for actual playback
    private var playerNode: AVAudioPlayerNode
    
    // The start frame for the current playback session (used to calculate seek position). Represents the point in the track at which playback began.
    private var startFrame: AVAudioFramePosition?
    
    // Cached seek position (used when looping, to remember last seek position and avoid displaying 0 when player is temporarily stopped at the end of a loop)
    private var lastSeekPosn: Double = 0
    
    init(_ playerNode: AVAudioPlayerNode) {
        
        self.playerNode = playerNode
        
        // Serial operation queue
        queue = OperationQueue()
        queue.underlyingQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.utility)
        queue.maxConcurrentOperationCount = 1
    }
    
    // Start track playback from the beginning
    func playTrack(_ playbackSession: PlaybackSession) {
        startPlaybackFromFrame(playbackSession, BufferManager.FRAME_ZERO)
    }
    
    // Starts track playback from a given frame position. The playbackSesssion parameter is used to ensure that no buffers are scheduled on the player for an old playback session.
    private func startPlaybackFromFrame(_ playbackSession: PlaybackSession, _ frame: AVAudioFramePosition) {
        
        // Can assume that audioFile is non-nil, because track has been prepared for playback
        let playingFile: AVAudioFile = playbackSession.track.playbackInfo!.audioFile!
        
        // Set the position in the audio file from which reading is to begin
        playingFile.framePosition = frame
        startFrame = frame
        
        // Schedule one buffer for immediate playback
        scheduleNextBuffer(playbackSession, BufferManager.BUFFER_SIZE_INITIAL)
        
        // Start playing the file
        playerNode.play()
        
        // Schedule one more ("look ahead") buffer
        if (!playbackSession.schedulingCompleted) {
            queue.addOperation({self.scheduleNextBuffer(playbackSession)})
        }
    }
    
    // Upon the completion of playback of a buffer, checks if more buffers are needed for the playback session, and if so, schedules one for playback. The playbackSession argument indicates which playback session this task was initiated for.
    private func bufferCompletionHandler(_ playbackSession: PlaybackSession) {
        
        if (PlaybackSession.isCurrent(playbackSession)) {
            
            if (playbackSession.playbackCompleted) {
                
                // Notify observers about playback completion
                AsyncMessenger.publishMessage(PlaybackCompletedAsyncMessage.instance)
                
            } else if (!playbackSession.schedulingCompleted) {
                
                // Continue scheduling more buffers
                queue.addOperation({self.scheduleNextBuffer(playbackSession)})
            }
        }
    }
    
    // Schedules a single audio buffer for playback of the specified track
    private func scheduleNextBuffer(_ playbackSession: PlaybackSession, _ bufferSize: UInt32 = BufferManager.BUFFER_SIZE) {
        
        // Can assume that track.playbackInfo is non-nil, because track has been prepared for playback
        let playingFile: AVAudioFile = playbackSession.track.playbackInfo!.audioFile!
        let length: AVAudioFramePosition = playbackSession.track.playbackInfo!.frames!
        
        let audioRead: (buffer: AVAudioPCMBuffer, eof: Bool) = AudioIO.readAudio(Double(bufferSize), playingFile, length)
        
        let buffer = audioRead.buffer
        let reachedEOF = audioRead.eof
        
        if (reachedEOF) {
            playbackSession.schedulingCompleted = true
        }
        
        // Redundant timestamp check, in case the disk read was slow and the session has changed since. This will come in handy when disk seeking suddenly slows down abnormally and the read task takes much longer to complete.
        if (PlaybackSession.isCurrent(playbackSession)) {
        
            playerNode.scheduleBuffer(buffer, at: nil, options: AVAudioPlayerNodeBufferOptions(), completionHandler: {
                
                if (reachedEOF) {
                    playbackSession.playbackCompleted = true
                }
                
                self.bufferCompletionHandler(playbackSession)
            })
        }
    }
    
    // MARK: Playback loop scheduling/playback
    
    // Start segment loop playback from the loop's start point
    func playLoop(_ playbackSession: PlaybackSession) {
        
        stop()
        
        let sampleRate = playbackSession.track.playbackInfo!.sampleRate!
        let loopStart = Int64(playbackSession.loop!.startTime * sampleRate)
        
        startLoopFromFrame(playbackSession, loopStart)
    }
    
    // Starts loop playback from a given frame position. The playbackSesssion parameter is used to ensure that no buffers are scheduled on the player for an old playback session.
    private func startLoopFromFrame(_ playbackSession: PlaybackSession, _ frame: AVAudioFramePosition) {
        
        // Can assume that audioFile is non-nil, because track has been prepared for playback
        let playingFile: AVAudioFile = playbackSession.track.playbackInfo!.audioFile!
        
        // Set the position in the audio file from which reading is to begin
        playingFile.framePosition = frame
        startFrame = frame
        
        // Schedule one buffer for immediate playback
        scheduleNextLoopBuffer(playbackSession, BufferManager.BUFFER_SIZE_INITIAL)
        
        // Start playing the file
        playerNode.play()
        
        // Schedule one more ("look ahead") buffer
        if (!playbackSession.schedulingCompleted) {
            queue.addOperation({self.scheduleNextLoopBuffer(playbackSession)})
        }
    }
    
    // When a playback loop is removed, scheduling should resume normally
    func endLoopScheduling(_ playbackSession: PlaybackSession) {
        
        playbackSession.playbackCompleted = false
        playbackSession.schedulingCompleted = false
        
        // Resume normal scheduling (as opposed to loop scheduling)
        queue.addOperation({self.scheduleNextBuffer(playbackSession, BufferManager.BUFFER_SIZE_INITIAL)})
        if (!playbackSession.schedulingCompleted) {
            queue.addOperation({self.scheduleNextBuffer(playbackSession)})
        }
    }
    
    // Upon the completion of playback of a buffer, checks if more buffers are needed for the playback session, and if so, schedules one for playback. The playbackSession argument indicates which playback session this task was initiated for.
    private func loopBufferCompletionHandler(_ playbackSession: PlaybackSession) {
        
        // Need to make sure loop still exists
        if (PlaybackSession.isCurrent(playbackSession) && playbackSession.hasCompleteLoop()) {
            
            if (playbackSession.playbackCompleted) {
                
                playbackSession.playbackCompleted = false
                playbackSession.schedulingCompleted = false
                
                // Replay loop
                playLoop(playbackSession)
                
            } else if (!playbackSession.schedulingCompleted) {
                
                // Continue scheduling more buffers
                queue.addOperation({self.scheduleNextLoopBuffer(playbackSession)})
            }
        }
    }
    
    // Schedules a single audio buffer for playback of the specified track
    private func scheduleNextLoopBuffer(_ playbackSession: PlaybackSession, _ bufferSize: UInt32 = BufferManager.BUFFER_SIZE) {
        
        // Can assume that track.playbackInfo is non-nil, because track has been prepared for playback
        let playingFile: AVAudioFile = playbackSession.track.playbackInfo!.audioFile!
        let sampleRate = playbackSession.track.playbackInfo!.sampleRate!
        let loopEndTime = playbackSession.loop!.endTime!
        let loopEndFrame: AVAudioFramePosition = Int64(loopEndTime * sampleRate)
        
        let totalFrames = AVAudioFrameCount(loopEndFrame - playingFile.framePosition)
        let maxFrames = AVAudioFrameCount(Double(bufferSize) * sampleRate)
        let framesToRead = min(totalFrames, maxFrames)
        
        let audioRead: (buffer: AVAudioPCMBuffer, eof: Bool) = AudioIO.readAudio(AVAudioFrameCount(framesToRead), playingFile, loopEndFrame)
        
        let buffer = audioRead.buffer
        let reachedEOF = audioRead.eof
        
        if (reachedEOF && playbackSession.hasCompleteLoop()) {
            playbackSession.schedulingCompleted = true
        }
        
        // Redundant timestamp check, in case the disk read was slow and the session has changed since. This will come in handy when disk seeking suddenly slows down abnormally and the read task takes much longer to complete.
        if (PlaybackSession.isCurrent(playbackSession)) {
            
            playerNode.scheduleBuffer(buffer, at: nil, options: AVAudioPlayerNodeBufferOptions(), completionHandler: {
                
                // Need to make sure the loop is still active
                if (reachedEOF && playbackSession.hasCompleteLoop()) {
                    playbackSession.playbackCompleted = true
                }
                
                self.loopBufferCompletionHandler(playbackSession)
            })
        }
    }
    
    // Seeks to a certain position (seconds) in the specified track. Returns the calculated start frame.
    func seekToTime(_ playbackSession: PlaybackSession, _ seconds: Double) {
        
        stop()
        
        // Can assume that track.audioFile is non-nil, because track has been prepared for playback
        let sampleRate = playbackSession.track.playbackInfo!.sampleRate!
        
        //  Multiply sample rate by the new time in seconds. This will give the exact start frame.
        let firstFrame = Int64(seconds * sampleRate)
        
        if (playbackSession.hasCompleteLoop()) {
            startLoopFromFrame(playbackSession, firstFrame)
        } else {
            startPlaybackFromFrame(playbackSession, firstFrame)
        }
    }
    
    // Stops the scheduling of audio buffers, in response to a request to stop playback (or when seeking to a new position). Waits till all previously scheduled buffers are cleared. After execution of this method, code can assume no scheduled buffers. Marks the end of a "playback session".
    func stop() {
        
        // Stop playback without clearing the player queue (and triggering the completion handlers)
        playerNode.pause()
        
        // Let the operation queue finish all tasks ... this may result in a stray buffer (if a task is currently executing) getting put on the player's schedule, but will be cleared by the following stop() call on playerNode
        queue.cancelAllOperations()
        queue.waitUntilAllOperationsAreFinished()
        
        // Flush out all player scheduled buffers and let their completion handlers execute (harmlessly)
        playerNode.stop()
    }
    
    // Retrieves the current seek position, in seconds
    func getSeekPosition() -> Double {
        
        if let nodeTime = playerNode.lastRenderTime {
            
            if let playerTime = playerNode.playerTime(forNodeTime: nodeTime) {
                lastSeekPosn = Double(startFrame! + playerTime.sampleTime) / playerTime.sampleRate
            }
        }
        
        // Default to last remembered position when nodeTime is nil
        return lastSeekPosn
    }
}
