
import Cocoa
import AVFoundation

/*
    Manages audio buffer allocation, scheduling, and playback. Provides two main operations - play() and seekToTime(). Works in conjunction with a playerNode to perform playback.

    A "playback session" begins when playback is started, as a result of either play() or seekToTime(). It ends when either playback is completed or a new request is received (and stop() is called).
*/
class BufferManager {
    
    // Indicates the beginning of a file, used when starting file playback
    static let FRAME_ZERO = AVAudioFramePosition(0)
    
    // Don't schedule buffers with less than this number of frames
    fileprivate static let MIN_PLAYBACK_FRAMES: Int64 = 1000
    
    // Seconds of playback
    fileprivate static let BUFFER_SIZE: UInt32 = 5
    
    // A constant to represent a timestamp in the past ... used to invalidate currently scheduled buffers and scheduling tasks. Used during the transition between two playback sessions (i.e. when stop() is called).
    fileprivate let INVALID_TIMESTAMP: Date
    
    // The (serial) dispatch queue on which all scheduling tasks will be enqueued
    fileprivate var queue: OperationQueue
    
    // Player node used for actual playback
    fileprivate var playerNode: AVAudioPlayerNode
    
    // The currently playing audio file
    fileprivate var playingFile: AVAudioFile?

    // This timestamp is used to mark which playback session a buffer scheduling task belongs to, i.e., it is a unique identifier for a playback session
    fileprivate var sessionTimestamp: Date = Date()
    
    init(playerNode: AVAudioPlayerNode) {
        
        self.playerNode = playerNode
        
        // Serial operation queue
        queue = OperationQueue()
        queue.underlyingQueue = DispatchQueue(queueName: "Aural.queues.bufferManager").underlyingQueue
        queue.maxConcurrentOperationCount = 1
        
        // Set the INVALID_TIMESTAMP constant to some time in the past
        let now = Date()
        let unitFlags: NSCalendar.Unit = [.year]
        let nowComponents = (Calendar.current as NSCalendar).components(unitFlags, from: now)
        
        var invalidTimestampComponents = DateComponents()
        invalidTimestampComponents.year = nowComponents.year! - 2
        
        INVALID_TIMESTAMP = (Calendar(identifier: Calendar.Identifier.gregorian).date(from: invalidTimestampComponents))!
    }
    
    // Start track playback from the beginning
    func play(_ avFile: AVAudioFile) {
        
        playingFile = avFile
        startPlaybackFromFrame(BufferManager.FRAME_ZERO)
    }
    
    // Starts track playback from a given frame position. Marks the beginning of a "playback session".
    fileprivate func startPlaybackFromFrame(_ frame: AVAudioFramePosition) {
        
        // Set the position in the audio file from which reading is to begin
        playingFile!.framePosition = frame
        
        // Mark the current playback session's timestamp
        sessionTimestamp = Date()
        
        // Schedule one buffer for immediate playback
        let reachedEOF = scheduleNextBuffer(sessionTimestamp)
        
        // Start playing the file
        playerNode.play()
        
        // Schedule one more ("look ahead") buffer
        if (!reachedEOF) {
            queue.addOperation({self.scheduleNextBuffer(self.sessionTimestamp)})
        }
    }
    
    // Upon the completion of playback of a buffer, checks if more buffers are needed for the playback session indicated by the given timestamp, and if so, schedules one for playback. The timestamp argument indicates which playback session this task was initiated for.
    fileprivate func bufferCompletionHandler(_ timestamp: Date, reachedEOF: Bool) {
        
        // If this timestamp doesn't match the current playback session timestamp, it is not current
        let timestampCurrent = timestamp.compare(sessionTimestamp) == ComparisonResult.orderedSame
        
        if (timestampCurrent) {
            
            if (reachedEOF) {
                
                // Notify observers about playback completion
                EventRegistry.publishEvent(EventType.playbackCompleted, event: PlaybackCompletedEvent.instance)
            } else {
                
                // Continue scheduling more buffers
                queue.addOperation({self.scheduleNextBuffer(timestamp)})
            }
        }
    }
    
    // Schedules a single audio buffer for playback
    // The timestamp argument indicates which playback session this task was initiated for
    fileprivate func scheduleNextBuffer(_ timestamp: Date) -> Bool {
        
        let sampleRate = playingFile!.processingFormat.sampleRate
        let buffer: AVAudioPCMBuffer = AVAudioPCMBuffer(pcmFormat: playingFile!.processingFormat, frameCapacity: AVAudioFrameCount(Double(BufferManager.BUFFER_SIZE) * sampleRate))
        
        do {
            try playingFile!.read(into: buffer)
        } catch let error as NSError {
            NSLog("Error reading from audio file '%@': %@", playingFile!.url.lastPathComponent, error.description)
        }
        
        let readAllFrames = playingFile!.framePosition >= playingFile!.length
        let bufferNotFull = buffer.frameLength < buffer.frameCapacity
        
        // If all frames have been read, OR the buffer is not full, consider track done playing (EOF)
        let reachedEOF = readAllFrames || bufferNotFull
        
        // Redundant timestamp check, in case the first one in scheduleNextBufferIfNecessary() was performed too soon (stop() called between scheduleNextBufferIfNecessary() and now). This will come in handy when disk seeking suddenly slows down abnormally and the task takes much longer to complete.
        let timestampCurrent = timestamp.compare(sessionTimestamp) == ComparisonResult.orderedSame
        
        if (timestampCurrent) {
        
            playerNode.scheduleBuffer(buffer, at: nil, options: AVAudioPlayerNodeBufferOptions(), completionHandler: {
                    self.bufferCompletionHandler(timestamp, reachedEOF: reachedEOF)
            })
        }
        
        return reachedEOF
    }
    
    // Seeks to a certain position (seconds) in the audio file being played back. Returns the calculated start frame and whether or not playback has completed after this seek (i.e. end of file)
    func seekToTime(_ seconds: Double) -> (playbackCompleted: Bool, startFrame: AVAudioFramePosition?) {
        
        stop()
        
        let sampleRate = playingFile!.processingFormat.sampleRate
        
        //  Multiply your sample rate by the new time in seconds. This will give you the exact frame of the song at which you want to start the player
        let firstFrame = Int64(seconds * sampleRate)

        let framesToPlay = playingFile!.length - firstFrame
        
        // If not enough frames left to play, consider playback finished
        if framesToPlay > 0 {
            
            // Start playback
            startPlaybackFromFrame(firstFrame)
            
            // Return the start frame to later determine seek position
            return (false, firstFrame)
            
        } else {
            
            // Nothing to play means playback has completed
            
            // Notify observers about playback completion
            EventRegistry.publishEvent(EventType.playbackCompleted, event: PlaybackCompletedEvent.instance)
            
            return (true, nil)
        }
    }
    
    // Stops the scheduling of audio buffers, in response to a request to stop playback (or when seeking to a new position). Waits till all previously scheduled buffers are cleared. After execution of this method, code can assume no scheduled buffers. Marks the end of a "playback session".
    func stop() {
        
        // Immediately invalidate all existing buffer scheduling tasks
        sessionTimestamp = INVALID_TIMESTAMP
        
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
