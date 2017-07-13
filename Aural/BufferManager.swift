
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
    private static let MIN_PLAYBACK_FRAMES: Int64 = 1000
    
    // Seconds of playback
    private static let BUFFER_SIZE: UInt32 = 5
    
    // A constant to represent a timestamp in the past ... used to invalidate currently scheduled buffers and scheduling tasks. Used during the transition between two playback sessions (i.e. when stop() is called).
    private let INVALID_TIMESTAMP: NSDate
    
    // The (serial) dispatch queue on which all scheduling tasks will be enqueued
    private var queue: NSOperationQueue
    
    // Player node used for actual playback
    private var playerNode: AVAudioPlayerNode
    
    // The currently playing audio file
    private var playingFile: AVAudioFile?
    
    // Flag marking if EOF has been reached when reading the current audio file
    private var reachedEOF: Bool = false
    
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
    
    // Starts track playback from a given frame position
    private func startPlaybackFromFrame(frame: AVAudioFramePosition) {
        
        // Set the position in the audio file from which reading is to begin
        playingFile!.framePosition = frame
        
        // Reset the EOF flag
        reachedEOF = false
        
        // Mark the current playback session's timestamp
        sessionTimestamp = NSDate()
        
        // Schedule one buffer for immediate playback
        scheduleNextBuffer(sessionTimestamp)
        
        // Start playing the file
        playerNode.play()
        
        // Schedule one more ("look ahead") buffer
        scheduleNextBufferIfNecessary(sessionTimestamp)
    }
    
    // Checks if more buffers are needed for the playback session indicated by the given timestamp, and if so, schedules one for playback. The timestamp argument indicates which playback session this task was initiated for. If the given timestamp does not match the current playback session timestamp, or the end of file has been reached, no scheduling will occur.
    private func scheduleNextBufferIfNecessary(timestamp: NSDate) {
        
        // This flag indicates whether this scheduling task belongs to the current playback session
        let timestampCurrent = timestamp.compare(sessionTimestamp) == NSComparisonResult.OrderedSame
        
        if (timestampCurrent && !reachedEOF) {
            queue.addOperationWithBlock({self.scheduleNextBuffer(timestamp)})
        }
    }
    
    // Schedules a single audio buffer for playback
    // The timestamp argument indicates which playback session this task was initiated for
    private func scheduleNextBuffer(timestamp: NSDate) {
        
        let sampleRate = playingFile!.processingFormat.sampleRate
        
        let buffer: AVAudioPCMBuffer = AVAudioPCMBuffer(PCMFormat: playingFile!.processingFormat, frameCapacity: AVAudioFrameCount(Double(BufferManager.BUFFER_SIZE) * sampleRate))
        
        do {
            try playingFile!.readIntoBuffer(buffer)
        } catch let error as NSError {
            NSLog("Error reading from audio file '%@': %@", playingFile!.url.lastPathComponent!, error.description)
        }
        
        let readAllFrames = playingFile!.framePosition >= playingFile!.length
        let bufferNotFull = buffer.frameLength < buffer.frameCapacity
        
        // If all frames have been read, OR the buffer is not full, consider track done playing (EOF)
        reachedEOF = readAllFrames || bufferNotFull
        
        // Redundant timestamp check, in case the first one in scheduleNextBufferIfNecessary() was performed too soon (stop() called between scheduleNextBufferIfNecessary() and now). This will come in handy when disk seeking suddenly slows down abnormally and the task takes much longer to complete.
        let timestampCurrent = timestamp.compare(sessionTimestamp) == NSComparisonResult.OrderedSame
        
        if (timestampCurrent && Int64(buffer.frameLength) >= BufferManager.MIN_PLAYBACK_FRAMES) {
        
            playerNode.scheduleBuffer(buffer, atTime: nil, options: AVAudioPlayerNodeBufferOptions(), completionHandler: {
                    self.scheduleNextBufferIfNecessary(timestamp)
            })
        }
    }
    
    // Seeks to a certain position (seconds) in the audio file being played back. Returns the calculated start frame and whether or not playback has completed after this seek (i.e. end of file)
    func seekToTime(seconds: Double) -> (playbackCompleted: Bool, startFrame: AVAudioFramePosition?) {
        
        stop()
        
        let sampleRate = playingFile!.processingFormat.sampleRate
        
        //  Multiply your sample rate by the new time in seconds. This will give you the exact frame of the song at which you want to start the player
        let firstFrame = Int64(seconds * sampleRate)
        
        let framesToPlay = playingFile!.length - firstFrame
        
        // If not enough frames left to play, consider playback finished
        if framesToPlay > BufferManager.MIN_PLAYBACK_FRAMES {
            
            // Start playback
            startPlaybackFromFrame(firstFrame)
            
            // Return the start frame to later determine seek position and end of file
            return (false, firstFrame)
            
        } else {
            
            // Reached end of track. Stop playback
            return (true, nil)
        }
    }
    
    // Stops the scheduling of audio buffers, in response to a request to stop playback (or when seeking to a new position). Waits till all previously scheduled buffers are cleared. After execution of this method, code can assume no scheduled buffers.
    func stop() {
        
        // Immediately invalidate all existing buffer scheduling tasks
        sessionTimestamp = INVALID_TIMESTAMP
        
        // Stop playback without clearing the player queue (and triggering the completion handlers)
        playerNode.pause()
        
        // Let the operation queue finish all tasks ... this may result in a stray buffer (if a task is currently executing) getting put on the player's schedule, but will be cleared by the following stop() call on playerNode
        queue.cancelAllOperations()
        queue.waitUntilAllOperationsAreFinished()
        
        // Flush out all player scheduled buffers and let their completion handlers execute (harmlessly)
        playerNode.stop()
    }
}