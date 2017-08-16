
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
    fileprivate static let BUFFER_SIZE: UInt32 = 15
    
    // The very first buffer should be small, so as to facilitate efficient immediate playback
    fileprivate static let BUFFER_SIZE_INITIAL: UInt32 = 5
    
    // The (serial) dispatch queue on which all scheduling tasks will be enqueued
    fileprivate var queue: OperationQueue
    
    // Player node used for actual playback
    fileprivate var playerNode: AVAudioPlayerNode
    
    init(playerNode: AVAudioPlayerNode) {
        
        self.playerNode = playerNode
        
        // Serial operation queue
        queue = OperationQueue()
        queue.underlyingQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.utility)
        queue.maxConcurrentOperationCount = 1
    }
    
    // Start track playback from the beginning
    func play(_ playbackSession: PlaybackSession) {
        startPlaybackFromFrame(playbackSession, BufferManager.FRAME_ZERO)
    }
    
    // Starts track playback from a given frame position. The playbackSesssion parameter is used to ensure that no buffers are scheduled on the player for an old playback session.
    fileprivate func startPlaybackFromFrame(_ playbackSession: PlaybackSession, _ frame: AVAudioFramePosition) {
        
        // Can assume that track.avFile is non-nil, because track has been prepared for playback
        let track: Track = playbackSession.track.track!
        let playingFile: AVAudioFile = track.avFile!
        
        // Set the position in the audio file from which reading is to begin
        playingFile.framePosition = frame
        
        // Mark the beginning of a new buffer scheduling session
        let schedulingSession = SchedulingSession()
        
        // Schedule one buffer for immediate playback
        scheduleNextBuffer(playbackSession, schedulingSession, BufferManager.BUFFER_SIZE_INITIAL)
        
        // Start playing the file
        playerNode.play()
        
        // Schedule one more ("look ahead") buffer
        if (!schedulingSession.schedulingCompleted) {
            queue.addOperation({self.scheduleNextBuffer(playbackSession, schedulingSession)})
        }
    }
    
    // Upon the completion of playback of a buffer, checks if more buffers are needed for the playback session, and if so, schedules one for playback. The playbackSession argument indicates which playback session this task was initiated for.
    fileprivate func bufferCompletionHandler(_ playbackSession: PlaybackSession, _ schedulingSession: SchedulingSession) {
        
        if (PlaybackSession.isCurrent(playbackSession)) {
            
            if (schedulingSession.playbackCompleted) {
                
                // Notify observers about playback completion
                EventRegistry.publishEvent(EventType.playbackCompleted, PlaybackCompletedEvent(playbackSession))
                
            } else if (!schedulingSession.schedulingCompleted) {
                
                // Continue scheduling more buffers
                queue.addOperation({self.scheduleNextBuffer(playbackSession, schedulingSession)})
            }
        }
    }
    
    // Schedules a single audio buffer for playback of the specified track
    // The timestamp argument indicates which playback session this task was initiated for
    fileprivate func scheduleNextBuffer(_ playbackSession: PlaybackSession, _ schedulingSession: SchedulingSession, _ bufferSize: UInt32 = BufferManager.BUFFER_SIZE) {
        
        // Can assume that track.avFile is non-nil, because track has been prepared for playback
        let track: Track = playbackSession.track.track!
        let playingFile: AVAudioFile = track.avFile!
        
        let sampleRate = playingFile.processingFormat.sampleRate
        let buffer: AVAudioPCMBuffer = AVAudioPCMBuffer(pcmFormat: playingFile.processingFormat, frameCapacity: AVAudioFrameCount(Double(bufferSize) * sampleRate))
        
        do {
            try playingFile.read(into: buffer)
        } catch let error as NSError {
            NSLog("Error reading from audio file '%@' atPos '%d': %@", playingFile.url.lastPathComponent, playingFile.framePosition, error.description)
        }
        
        let readAllFrames = playingFile.framePosition >= track.frames!
        let bufferNotFull = buffer.frameLength < buffer.frameCapacity
        
        // If all frames have been read, OR the buffer is not full, consider track done playing (EOF)
        let reachedEOF = readAllFrames || bufferNotFull
        if (reachedEOF) {
            schedulingSession.schedulingCompleted = true
        }
        
        // Redundant timestamp check, in case the first one in scheduleNextBufferIfNecessary() was performed too soon (stop() called between scheduleNextBufferIfNecessary() and now). This will come in handy when disk seeking suddenly slows down abnormally and the task takes much longer to complete.
        if (PlaybackSession.isCurrent(playbackSession)) {
        
            playerNode.scheduleBuffer(buffer, at: nil, options: AVAudioPlayerNodeBufferOptions(), completionHandler: {
                
                if (reachedEOF) {
                    schedulingSession.playbackCompleted = true
                }
                self.bufferCompletionHandler(playbackSession, schedulingSession)
            })
        }
    }
    
    // Seeks to a certain position (seconds) in the specified track. Returns the calculated start frame and whether or not playback has completed after this seek (i.e. end of file)
    func seekToTime(_ playbackSession: PlaybackSession, _ seconds: Double) -> (playbackCompleted: Bool, startFrame: AVAudioFramePosition?) {
        
        stop()
        
        // Can assume that track.avFile is non-nil, because track has been prepared for playback
        let track: Track = playbackSession.track.track!
        let playingFile: AVAudioFile = track.avFile!
        let sampleRate = playingFile.processingFormat.sampleRate
        
        //  Multiply your sample rate by the new time in seconds. This will give you the exact frame of the song at which you want to start the player
        let firstFrame = Int64(seconds * sampleRate)
        let framesToPlay = track.frames! - firstFrame
        
        // If not enough frames left to play, consider playback finished
        if framesToPlay > 0 {
            
            // Start playback
            startPlaybackFromFrame(playbackSession, firstFrame)
            
            // Return the start frame to later determine seek position
            return (false, firstFrame)
            
        } else {
            
            // Nothing to play means playback has completed
            
            // Notify observers about playback completion
            // TODO: This clause is unnecessary because this method will never get called with 0 frames to play
            
            let thisSession = PlaybackSession.currentSession!
            EventRegistry.publishEvent(EventType.playbackCompleted, PlaybackCompletedEvent(thisSession))
            
            return (true, nil)
        }
    }
    
    // Stops the scheduling of audio buffers, in response to a request to stop playback (or when seeking to a new position). Waits till all previously scheduled buffers are cleared. After execution of this method, code can assume no scheduled buffers. Marks the end of a "playback session".
    func stop() {
        
        // Stop playback without clearing the player queue (and triggering the completion handlers)
        // WARNING - This might be causing problems
        playerNode.pause()
        
        // Let the operation queue finish all tasks ... this may result in a stray buffer (if a task is currently executing) getting put on the player's schedule, but will be cleared by the following stop() call on playerNode
        queue.cancelAllOperations()
        queue.waitUntilAllOperationsAreFinished()
        
        // Flush out all player scheduled buffers and let their completion handlers execute (harmlessly)
        playerNode.stop()
    }
}
