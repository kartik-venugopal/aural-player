
import Cocoa
import AVFoundation

/*
Manages audio buffer allocation, scheduling, and playback. Provides two main operations - play() and seekToTime(). Works in conjunction with a playerNode to perform playback.

A "playback session" begins when playback is started, as a result of either play() or seekToTime(). It ends when either playback is completed or a new request is received (and stop() is called).
*/
class QueueBasedBufferManager {
    
    // Indicates the beginning of a file, used when starting file playback
    static let FRAME_ZERO = AVAudioFramePosition(0)
    
    // Seconds of playback
    private static let BUFFER_SIZE: UInt32 = 15
    
    // A constant to represent a timestamp in the past ... used to invalidate currently scheduled buffers and scheduling tasks. Used during the transition between two playback sessions (i.e. when stop() is called).
    private let INVALID_TIMESTAMP: NSDate
    
    // The (serial) dispatch queue on which all scheduling tasks will be enqueued
    private var queue: NSOperationQueue
    
    // Player node used for actual playback
    private var playerNode: AVAudioPlayerNode
    
    // The currently playing audio file
    private var playingFile: AVAudioFile?
    
    // This timestamp is used to mark which playback session a buffer scheduling task belongs to, i.e., it is a unique identifier for a playback session
    private var sessionTimestamp: NSDate = NSDate()
    
    init(playerNode: AVAudioPlayerNode) {
        
        self.playerNode = playerNode
        
        // Serial operation queue
        queue = NSOperationQueue()
        queue.underlyingQueue = DispatchQueue(queueName: "Aural.queues.bufferManager").underlyingQueue
        queue.maxConcurrentOperationCount = 1
        
        // Set the INVALID_TIMESTAMP constant to some time in the past
        let now = NSDate()
        let unitFlags: NSCalendarUnit = [.Year]
        let nowComponents = NSCalendar.currentCalendar().components(unitFlags, fromDate: now)
        
        let invalidTimestampComponents = NSDateComponents()
        invalidTimestampComponents.year = nowComponents.year - 2
        
        INVALID_TIMESTAMP = (NSCalendar(identifier: NSCalendarIdentifierGregorian)?.dateFromComponents(invalidTimestampComponents))!
    }
    
    // Start track playback from the beginning
    func play(avFile: AVAudioFile) {
        
        playingFile = avFile
        startPlaybackFromFrame(BufferManager.FRAME_ZERO)
    }
    
    // Starts track playback from a given frame position. Marks the beginning of a "playback session".
    private func startPlaybackFromFrame(frame: AVAudioFramePosition) {
        
        // Set the position in the audio file from which reading is to begin
        playingFile!.framePosition = frame
        
        // Mark the current playback session's timestamp
        sessionTimestamp = NSDate()
        
        // Schedule one buffer for immediate playback
        let reachedEOF = scheduleNextBuffer(sessionTimestamp)
        
        // Start playing the file
        playerNode.play()
        
        // Schedule one more ("look ahead") buffer
        if (!reachedEOF) {
            queue.addOperationWithBlock({self.scheduleNextBuffer(sessionTimestamp)})
        }
    }
    
    // Upon the completion of playback of a buffer, checks if more buffers are needed for the playback session indicated by the given timestamp, and if so, schedules one for playback. The timestamp argument indicates which playback session this task was initiated for.
    private func bufferCompletionHandler(timestamp: NSDate, reachedEOF: Bool) {
        
        // If this timestamp doesn't match the current playback session timestamp, it is not current
        let timestampCurrent = timestamp.compare(sessionTimestamp) == NSComparisonResult.OrderedSame
        
        if (timestampCurrent) {
            
            if (reachedEOF) {
                
                // Notify observers about playback completion
                EventRegistry.publishEvent(EventType.PlaybackCompleted, event: PlaybackCompletedEvent.instance)
            } else {
                
                // Continue scheduling more buffers
                queue.addOperationWithBlock({self.scheduleNextBuffer(timestamp)})
            }
        }
    }
    
    // Schedules a single audio buffer for playback
    // The timestamp argument indicates which playback session this task was initiated for
    private func scheduleNextBuffer(timestamp: NSDate) -> Bool {
        
        let sampleRate = playingFile!.processingFormat.sampleRate
        let buffer: AVAudioPCMBuffer = AVAudioPCMBuffer(PCMFormat: playingFile!.processingFormat, frameCapacity: AVAudioFrameCount(Double(QueueBasedBufferManager.BUFFER_SIZE) * sampleRate))
        
        do {
            try playingFile!.readIntoBuffer(buffer)
        } catch let error as NSError {
            NSLog("Error reading from audio file '%@': %@", playingFile!.url.lastPathComponent!, error.description)
        }
        
        let readAllFrames = playingFile!.framePosition >= playingFile!.length
        let bufferNotFull = buffer.frameLength < buffer.frameCapacity
        
        // If all frames have been read, OR the buffer is not full, consider track done playing (EOF)
        let reachedEOF = readAllFrames || bufferNotFull
        
        // Redundant timestamp check, in case the first one in scheduleNextBufferIfNecessary() was performed too soon (stop() called between scheduleNextBufferIfNecessary() and now). This will come in handy when disk seeking suddenly slows down abnormally and the task takes much longer to complete.
        let timestampCurrent = timestamp.compare(sessionTimestamp) == NSComparisonResult.OrderedSame
        
        if (timestampCurrent) {
            
            playerNode.scheduleBuffer(buffer, atTime: nil, options: AVAudioPlayerNodeBufferOptions(), completionHandler: {
                self.bufferCompletionHandler(timestamp, reachedEOF: reachedEOF)
            })
        }
        
        return reachedEOF
    }
    
    // Seeks to a certain position (seconds) in the audio file being played back. Returns the calculated start frame and whether or not playback has completed after this seek (i.e. end of file)
    func seekToTime(seconds: Double) -> (playbackCompleted: Bool, startFrame: AVAudioFramePosition?) {
        
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
            EventRegistry.publishEvent(EventType.PlaybackCompleted, event: PlaybackCompletedEvent.instance)
            
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