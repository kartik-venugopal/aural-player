//
//import Cocoa
//import AVFoundation
//
///*
// Manages audio buffer allocation, scheduling, and playback. Provides two main operations - play() and seekToTime(). Works in conjunction with a playerNode to perform playback.
// 
// A "playback session" begins when playback is started, as a result of either play() or seekToTime(). It ends when either playback is completed or a new request is received (and stop() is called).
// */
//
//// TODO: Consolidate PlaybackSession and SchedulingSession
//// TODO: When seeking, if data is already available, copy into new buffer from memory, instead of reading the same data from disk again (to achieve this, add wrapper around PCMBuffer, with fields (startTime, endTime) and use those fields to check if this buffer has the desired data)
//class BufferManager {
//    
//    // Indicates the beginning of a file, used when starting file playback
//    static let FRAME_ZERO = AVAudioFramePosition(0)
//    
//    // Seconds of playback
//    private static let BUFFER_SIZE: UInt32 = 15
//    
//    // The very first buffer should be small, so as to facilitate efficient immediate playback
//    private static let BUFFER_SIZE_INITIAL: UInt32 = 5
//    
//    // The (serial) dispatch queue on which all scheduling tasks will be enqueued
//    private var queue: OperationQueue
//    
//    // Player node used for actual playback
//    private var playerNode: AVAudioPlayerNode
//    
//    init(_ playerNode: AVAudioPlayerNode) {
//        
//        self.playerNode = playerNode
//        
//        // Serial operation queue
//        queue = OperationQueue()
//        queue.underlyingQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.utility)
//        queue.maxConcurrentOperationCount = 1
//    }
//    
//    // Start track playback from the beginning
//    func play(_ playbackSession: PlaybackSession) {
//        startPlaybackFromFrame(playbackSession, BufferManager.FRAME_ZERO)
//    }
//    
//    // Starts track playback from a given frame position. The playbackSesssion parameter is used to ensure that no buffers are scheduled on the player for an old playback session.
//    private func startPlaybackFromFrame(_ playbackSession: PlaybackSession, _ frame: AVAudioFramePosition) {
//        
//        // Can assume that avFile is non-nil, because track has been prepared for playback
//        let playingFile: AVAudioFile = playbackSession.track.playbackInfo!.avFile!
//        
//        // Set the position in the audio file from which reading is to begin
//        playingFile.framePosition = frame
//        
//        // Mark the beginning of a new buffer scheduling session
//        let schedulingSession = SchedulingSession()
//        
//        BufferCache.clear()
//        
//        // Schedule one buffer for immediate playback
//        scheduleNextBuffer(playbackSession, schedulingSession, BufferManager.BUFFER_SIZE_INITIAL)
//        
//        // Start playing the file
//        playerNode.play()
//        
//        // Schedule one more ("look ahead") buffer
//        if (!schedulingSession.schedulingCompleted) {
//            queue.addOperation({self.scheduleNextBuffer(playbackSession, schedulingSession)})
//        }
//    }
//    
//    private func startPlaybackFromBuffer(_ playbackSession: PlaybackSession, _ buffer: TrackAwareBuffer) {
//        
//        print("Starting playback from sub")
//        
//        // Mark the beginning of a new buffer scheduling session
//        let schedulingSession = SchedulingSession()
//        if (buffer.reachedEOF) {
//            schedulingSession.schedulingCompleted = true
//        }
//        
//        BufferCache.clear()
//        
//        // Schedule one buffer for immediate playback
//        print("Calling scheduleBuffer()")
//        scheduleBuffer(playbackSession, schedulingSession, buffer)
//        
//        print("Playing ...")
//        // Start playing the file
//        playerNode.play()
//        
//        // Schedule one more ("look ahead") buffer
//        if (!schedulingSession.schedulingCompleted) {
//            queue.addOperation({self.scheduleNextBuffer(playbackSession, schedulingSession)})
//        }
//    }
//    
//    // Upon the completion of playback of a buffer, checks if more buffers are needed for the playback session, and if so, schedules one for playback. The playbackSession argument indicates which playback session this task was initiated for.
//    private func bufferCompletionHandler(_ playbackSession: PlaybackSession, _ schedulingSession: SchedulingSession) {
//        
//        if (PlaybackSession.isCurrent(playbackSession)) {
//            
//            if (schedulingSession.playbackCompleted) {
//                
//                // Notify observers about playback completion
//                AsyncMessenger.publishMessage(PlaybackCompletedAsyncMessage(playbackSession))
//                
//            } else if (!schedulingSession.schedulingCompleted) {
//                
//                // Continue scheduling more buffers
//                queue.addOperation({self.scheduleNextBuffer(playbackSession, schedulingSession)})
//            }
//        }
//    }
//    
//    private func scheduleBuffer(_ playbackSession: PlaybackSession, _ schedulingSession: SchedulingSession, _ buffer: TrackAwareBuffer) {
//        
//        print("scheduleBuffer()")
//        
//        // Redundant timestamp check, in case the first one in scheduleNextBufferIfNecessary() was performed too soon (stop() called between scheduleNextBufferIfNecessary() and now). This will come in handy when disk seeking suddenly slows down abnormally and the task takes much longer to complete.
//        if (PlaybackSession.isCurrent(playbackSession)) {
//            
//            playerNode.scheduleBuffer(buffer, at: nil, options: AVAudioPlayerNodeBufferOptions(), completionHandler: {
//                
//                if (buffer.reachedEOF) {
//                    schedulingSession.playbackCompleted = true
//                }
//                self.bufferCompletionHandler(playbackSession, schedulingSession)
//            })
//            
//            let seconds = Double(buffer.frameLength) / buffer.sampleRate
//            print("Scheduled subBuffer ! with", seconds, "seconds of data")
//            BufferCache.addBuffer(buffer)
//            
//        } else {
//            
//            print("session not current !")
//        }
//    }
//    
//    // Schedules a single audio buffer for playback of the specified track
//    // The timestamp argument indicates which playback session this task was initiated for
//    private func scheduleNextBuffer(_ playbackSession: PlaybackSession, _ schedulingSession: SchedulingSession, _ bufferSize: UInt32 = BufferManager.BUFFER_SIZE) {
//        
//        // Can assume that track.avFile is non-nil, because track has been prepared for playback
//        let playbackInfo = playbackSession.track.playbackInfo!
//        let playingFile: AVAudioFile = playbackInfo.avFile!
//        
//        let buffer: TrackAwareBuffer = TrackAwareBuffer(playingFile, AVAudioFrameCount(Double(bufferSize) * playbackInfo.sampleRate!))
//        
//        let reachedEOF = buffer.readFromFile()
//        if (reachedEOF) {
//            schedulingSession.schedulingCompleted = true
//        }
//        
//        // Redundant timestamp check, in case the first one in scheduleNextBufferIfNecessary() was performed too soon (stop() called between scheduleNextBufferIfNecessary() and now). This will come in handy when disk seeking suddenly slows down abnormally and the task takes much longer to complete.
//        if (PlaybackSession.isCurrent(playbackSession)) {
//            
//            playerNode.scheduleBuffer(buffer, at: nil, options: AVAudioPlayerNodeBufferOptions(), completionHandler: {
//                
//                if (reachedEOF) {
//                    schedulingSession.playbackCompleted = true
//                }
//                self.bufferCompletionHandler(playbackSession, schedulingSession)
//            })
//            
//            BufferCache.addBuffer(buffer)
//        }
//    }
//    
//    // Seeks to a certain position (seconds) in the specified track. Returns the calculated start frame.
//    func seekToTime(_ playbackSession: PlaybackSession, _ seconds: Double) -> AVAudioFramePosition {
//        
//        stop()
//        
//        // Can assume that track.avFile is non-nil, because track has been prepared for playback
//        let sampleRate = playbackSession.track.playbackInfo!.sampleRate!
//        
//        //  Multiply sample rate by the new time in seconds. This will give the exact start frame.
//        let firstFrame = Int64(seconds * sampleRate)
//        
//        
//        let buf = BufferCache.bufferForPos(seconds)
//        
//        
//        
//        if (buf != nil) {
//            
//            let tim = TimerUtils.start("seekNew")
//            
//            let sub = buf!.subBuffer(firstFrame)
//            startPlaybackFromBuffer(playbackSession, sub)
//            
//            tim.end()
//            return firstFrame
//        }
//        
//        let tim = TimerUtils.start("seekOld")
//        // Start playback
//        startPlaybackFromFrame(playbackSession, firstFrame)
//        
//        tim.end()
//        
//        return firstFrame
//    }
//    
//    // Stops the scheduling of audio buffers, in response to a request to stop playback (or when seeking to a new position). Waits till all previously scheduled buffers are cleared. After execution of this method, code can assume no scheduled buffers. Marks the end of a "playback session".
//    func stop() {
//        
//        // Stop playback without clearing the player queue (and triggering the completion handlers)
//        // WARNING - This might be causing problems
//        playerNode.pause()
//        
//        // Let the operation queue finish all tasks ... this may result in a stray buffer (if a task is currently executing) getting put on the player's schedule, but will be cleared by the following stop() call on playerNode
//        queue.cancelAllOperations()
//        queue.waitUntilAllOperationsAreFinished()
//        
//        // Flush out all player scheduled buffers and let their completion handlers execute (harmlessly)
//        playerNode.stop()
//    }
//}
