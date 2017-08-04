
import Cocoa
import AVFoundation

/*
    Manages audio buffer allocation, scheduling, and playback. Provides two main operations - play() and seekToTime(). Works in conjunction with a playerNode to perform playback.

    A "playback session" begins when playback is started, as a result of either play() or seekToTime(). It ends when either playback is completed or a new request is received (and stop() is called).
*/
class BufferManager {
    
    // Indicates the beginning of a file, used when starting file playback
    static let FRAME_ZERO = AVAudioFramePosition(0)
    
    // The (serial) dispatch queue on which all scheduling tasks will be enqueued
    fileprivate var queue: OperationQueue
    
    // Player node used for actual playback
    fileprivate var playerNode: AVAudioPlayerNode
    
    init(playerNode: AVAudioPlayerNode) {
        
        self.playerNode = playerNode
        
        // Serial operation queue
        queue = OperationQueue()
        queue.underlyingQueue = GCDDispatchQueue(queueName: "Aural.queues.bufferManager").underlyingQueue
        queue.maxConcurrentOperationCount = 1
    }
    
    // Start track playback from the beginning
    // TODO - Maybe, instead of passing in Track, pass in TrackPlaybackData ?
    func play(_ track: Track) {
        startPlaybackFromFrame(track, BufferManager.FRAME_ZERO, true)
    }
    
    // Starts track playback from a given frame position. Marks the beginning of a "playback session". The checkCache argument specifies whether or not to look for a cached audio buffer for this track (and if found, to use it as the initial playback buffer). Typically, checkCache will be true when starting track playback, and false otherwise.
    fileprivate func startPlaybackFromFrame(_ track: Track, _ frame: AVAudioFramePosition, _ checkCache: Bool = false) {
        
        // Mark the current playback session and use it when scheduling buffers
        // NOTE - Assume that the playback session has not changed since this request was initiated
        let thisSession = PlaybackSession.currentSession!
        
        var useCachedBuffer: Bool = false
        var cachedInitialBuffer: (buffer: AVAudioPCMBuffer, reachedEOF: Bool)? = nil
        
        // If cache needs to be checked, ensure that it has a buffer for this track
        if (checkCache) {
            cachedInitialBuffer = AudioBufferCache.getForTrack(track)
            useCachedBuffer = cachedInitialBuffer != nil
        }
        
        print("\nuseCachedBuffer", useCachedBuffer, track.shortDisplayName!)
        
        // This flag will determine whether or not to schedule a second "look ahead" buffer
        var reachedEOF: Bool
        
        // This condition will be true if and only if checkCache is true AND there is a cached buffer for this track
        if (useCachedBuffer) {
        // TODO: Temporarily disabling useCachedBuffer
//        if (false) {
        
            reachedEOF = cachedInitialBuffer!.reachedEOF
            scheduleCachedBuffer(thisSession, track, cachedInitialBuffer!.buffer, reachedEOF)
            
            // Invalidate this buffer
//            AudioBufferCache.removeForTrack(track)
//            NSLog("Removed for %@", track.shortDisplayName!)
            
        } else {
            
            // Can assume that track.avFile is non-nil, because track has been prepared for playback
            let playingFile: AVAudioFile = track.avFile!
            
            // Set the position in the audio file from which reading is to begin
            playingFile.framePosition = frame
            
            // Schedule one buffer for immediate playback
            reachedEOF = readAndScheduleBuffer(thisSession, track, AppConstants.audioBufferSize_initial)
        }
        
        // Start playing the file
        playerNode.play()
//        NSLog("Started playing the fucking file! %@", track.shortDisplayName!)
        
        // Schedule one more ("look ahead") buffer
        if (!reachedEOF) {
            queue.addOperation({self.readAndScheduleBuffer(thisSession, track)})
        }
    }
    
    // Schedules a single audio buffer for playback of the specified track
    // The timestamp argument indicates which playback session this task was initiated for
    fileprivate func scheduleCachedBuffer(_ session: PlaybackSession, _ track: Track, _ buffer: AVAudioPCMBuffer, _ reachedEOF: Bool) {
        
        print("\nBefore useCache:", track.avFile!.framePosition, track.avFile?.hashValue)
        
        // Redundant timestamp check, in case the first one in scheduleNextBufferIfNecessary() was performed too soon (stop() called between scheduleNextBufferIfNecessary() and now). This will come in handy when disk seeking suddenly slows down abnormally and the task takes much longer to complete.
        
        if (PlaybackSession.isCurrentAndActive(session)) {
            
//            playerNode.scheduleBuffer(buffer, at: nil, options: AVAudioPlayerNodeBufferOptions(), completionHandler: nil)
            
            playerNode.scheduleBuffer(buffer, at: nil, options: AVAudioPlayerNodeBufferOptions(), completionHandler: {
                self.bufferCompletionHandler(session, track, reachedEOF)
            })
        }
        
        // Advance the frame position of the AVAudioFile so that subsequent reading will resume at the appropriate position
        let playingFile: AVAudioFile = track.avFile!
        playingFile.framePosition = AVAudioFramePosition(buffer.frameLength)
        
        print("After useCache:", track.avFile!.framePosition, track.avFile?.hashValue)
    }
    
    // Upon the completion of playback of a buffer, checks if more buffers are needed for the playback session, and if so, schedules one for playback. The session argument indicates which playback session this task was initiated for.
    fileprivate func bufferCompletionHandler(_ session: PlaybackSession, _ track: Track, _ reachedEOF: Bool) {
        
        if (PlaybackSession.isCurrentAndActive(session)) {
            
            if (reachedEOF) {
                
                // End this playback session and notify observers about playback completion
                PlaybackSession.end(session)
                EventRegistry.publishEvent(EventType.playbackCompleted, PlaybackCompletedEvent(session))
                
            } else {
                
                // Continue scheduling more buffers
                queue.addOperation({self.readAndScheduleBuffer(session, track)})
            }
        }
    }
    
    // Schedules a single audio buffer for playback of the specified track
    // The timestamp argument indicates which playback session this task was initiated for
    fileprivate func readAndScheduleBuffer(_ session: PlaybackSession, _ track: Track, _ bufferSize: UInt32 = AppConstants.audioBufferSize) -> Bool {
        
        print("\nBefore read:", track.avFile!.framePosition, track.avFile?.hashValue)
        
        // Can assume that track.avFile is non-nil, because track has been prepared for playback
        let playingFile: AVAudioFile = track.avFile!
        
        let sampleRate = playingFile.processingFormat.sampleRate
        let buffer: AVAudioPCMBuffer = AVAudioPCMBuffer(pcmFormat: playingFile.processingFormat, frameCapacity: AVAudioFrameCount(Double(bufferSize) * sampleRate))
        
        do {
            try playingFile.read(into: buffer)
            
            print("After read:", track.avFile!.framePosition, track.avFile?.hashValue)
            
        } catch let error as NSError {
            NSLog("Error reading from audio file '%@': %@", playingFile.url.lastPathComponent, error.description)
        }
        
        let readAllFrames = playingFile.framePosition >= track.frames!
        let bufferNotFull = buffer.frameLength < buffer.frameCapacity
        
        // If all frames have been read, OR the buffer is not full, consider track done playing (EOF)
        let reachedEOF = readAllFrames || bufferNotFull
        
        // Redundant timestamp check, in case the first one in scheduleNextBufferIfNecessary() was performed too soon (stop() called between scheduleNextBufferIfNecessary() and now). This will come in handy when disk seeking suddenly slows down abnormally and the task takes much longer to complete.
        
        if (PlaybackSession.isCurrentAndActive(session)) {
        
            playerNode.scheduleBuffer(buffer, at: nil, options: AVAudioPlayerNodeBufferOptions(), completionHandler: {
                    self.bufferCompletionHandler(session, track, reachedEOF)
            })
        }
        
        return reachedEOF
    }
    
    // Seeks to a certain position (seconds) in the specified track. Returns the calculated start frame and whether or not playback has completed after this seek (i.e. end of file)
    func seekToTime(_ track: Track, _ seconds: Double) -> (playbackCompleted: Bool, startFrame: AVAudioFramePosition?) {
        
        stop()
        
        // Can assume that track.avFile is non-nil, because track has been prepared for playback
        let playingFile: AVAudioFile = track.avFile!
        let sampleRate = playingFile.processingFormat.sampleRate
        
        //  Multiply your sample rate by the new time in seconds. This will give you the exact frame of the song at which you want to start the player
        let firstFrame = Int64(seconds * sampleRate)
        let framesToPlay = track.frames! - firstFrame
        
        // If not enough frames left to play, consider playback finished
        if framesToPlay > 0 {
            
            // Start playback
            startPlaybackFromFrame(track, firstFrame)
            
            // Return the start frame to later determine seek position
            return (false, firstFrame)
            
        } else {
            
            // Nothing to play means playback has completed
            
            // Notify observers about playback completion
            // TODO: Don't need both return flag and event. Eliminate one.
            
            let thisSession = PlaybackSession.currentSession!
            PlaybackSession.end(thisSession)
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
