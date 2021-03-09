import AVFoundation

class FFmpegScheduler: PlaybackSchedulerProtocol {
    
    ///
    /// The number of audio buffers currently scheduled for playback by the player.
    ///
    /// Used to determine:
    /// 1. when playback has completed.
    /// 2. whether or not a scheduling task was successful and whether or not playback should begin.
    ///
    var scheduledBufferCount: AtomicCounter<Int> = AtomicCounter<Int>()
    
    ///
    /// A flag indicating whether or not the decoder has reached the end of the currently playing file's audio stream, i.e. EOF..
    ///
    /// This value is used to make decisions about whether or not to continue scheduling and / or to signal completion
    /// of playback.
    ///
    var eof: Bool {decoder.eof}
    
    // Player node used for actual playback
    let playerNode: AuralPlayerNode
    
    var playbackCtx: FFmpegPlaybackContext!
    
    /// A helper object that does the actual decoding.
    var decoder: FFmpegDecoder! {playbackCtx?.decoder}
    
    let sampleConverter: SampleConverterProtocol
    
    ///
    /// A **serial** operation queue on which all *deferred* scheduling tasks are enqueued, i.e. tasks scheduling buffers that will be played back at a later time.
    ///
    /// ```
    /// The use of this queue allows monitoring and cancellation of scheduling tasks
    /// (e.g. when seeking invalidates previous scheduling tasks).
    /// ```
    /// # Notes #
    ///
    /// 1. Uses the global dispatch queue.
    ///
    /// 2. This is a *serial* queue, meaning that only one operation can execute at any given time. This is very important, because we don't want a race condition when scheduling buffers.
    ///
    /// 3. Scheduling tasks for *immediate* playback will **not** be enqueued on this queue. They will be run immediately on the main thread.
    ///
    lazy var schedulingOpQueue: OperationQueue = {
        
        let queue = OperationQueue()
        queue.underlyingQueue = DispatchQueue.global(qos: .userInitiated)
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        
        return queue
    }()
    
    init(playerNode: AuralPlayerNode, sampleConverter: SampleConverterProtocol) {
        
        self.playerNode = playerNode
        self.sampleConverter = sampleConverter
    }
    
    func playTrack(_ session: PlaybackSession, _ startPosition: Double) {
        
        stop()
        scheduledBufferCount.value = 0
        
        guard let thePlaybackCtx = session.track.playbackContext as? FFmpegPlaybackContext else {return}
        self.playbackCtx = thePlaybackCtx
        
        initiateDecodingAndScheduling(for: session, from: startPosition == 0 ? nil : startPosition)
        
        // Check that at least one audio buffer was successfully scheduled, before beginning playback.
        if scheduledBufferCount.isPositive {
            playerNode.play()
        }
    }
    
    ///
    /// Initiates decoding and scheduling for the currently chosen audio file, either from the start of the file, or from a given seek position.
    ///
    /// - Parameter seekPosition: An (optional) time value, specified in seconds, denoting a seek position within the
    ///                             currently playing file's audio stream. May be nil. A nil value indicates start decoding
    ///                             and scheduling from the beginning of the stream.
    ///
    /// ```
    /// Each scheduled buffer, when it finishes playing, will recursively decode / schedule one more
    /// buffer. So, in essence, this function initiates a recursive decoding / scheduling loop that
    /// terminates only when there is no more audio to play, i.e. EOF.
    /// ```
    ///
    /// # Notes #
    ///
    /// If the **seekPosition** parameter given is greater than the currently playing file's audio stream duration, this function
    /// will signal completion of playback for the file.
    ///
    func initiateDecodingAndScheduling(for session: PlaybackSession, from seekPosition: Double? = nil) {
        
        do {
            
            // If a seek position was specified, ask the decoder to seek
            // within the stream.
            if let theSeekPosition = seekPosition {
                
                try decoder.seek(to: theSeekPosition)
                
                // If the seek took the decoder to EOF, signal completion of playback
                // and don't do any scheduling.
                if eof {
                    
                    trackCompleted(session)
                    return
                }
            }
            
            // Schedule one buffer for immediate playback
            decodeAndScheduleOneBuffer(for: session, from: seekPosition ?? 0, immediatePlayback: true, maxSampleCount: playbackCtx.sampleCountForImmediatePlayback)
            
            // Schedule a second buffer asynchronously, for later, to avoid a gap in playback.
            decodeAndScheduleOneBufferAsync(for: session, maxSampleCount: playbackCtx.sampleCountForDeferredPlayback)
            
        } catch {
            print("\nDecoder threw error: \(error)")
        }
    }
    
    ///
    /// Asynchronously decodes and schedules a single audio buffer, of the given size (sample count), for playback.
    ///
    /// - Parameter maxSampleCount: The maximum number of samples to be decoded and scheduled for playback.
    ///
    /// # Notes #
    ///
    /// 1. If the decoder has already reached EOF prior to this function being called, nothing will be done. This function will
    /// simply return.
    ///
    /// 2. Since the task is enqueued on an OperationQueue (whose underlying queue is the global DispatchQueue),
    /// this function will not block the caller, i.e. the main thread, while the task executes.
    ///
    func decodeAndScheduleOneBufferAsync(for session: PlaybackSession, maxSampleCount: Int32) {
        
        if eof {return}
        
        self.schedulingOpQueue.addOperation {
            self.decodeAndScheduleOneBuffer(for: session, immediatePlayback: false, maxSampleCount: maxSampleCount)
        }
    }

    ///
    /// Decodes and schedules a single audio buffer, of the given size (sample count), for playback.
    ///
    /// - Parameter maxSampleCount: The maximum number of samples to be decoded and scheduled for playback.
    ///
    /// ```
    /// Delegates to the decoder to decode and buffer a pre-determined (maximum) number of samples.
    ///
    /// Once the decoding is done, an AVAudioPCMBuffer is created from the decoder output, which is
    /// then actually sent to the audio engine for scheduling.
    /// ```
    /// # Notes #
    ///
    /// 1. If the decoder has already reached EOF prior to this function being called, nothing will be done. This function will
    /// simply return.
    ///
    /// 2. If the decoder reaches EOF when invoked from this function call, the number of samples decoded (and subsequently scheduled)
    /// may be less than the maximum sample count specified by the **maxSampleCount** parameter. However, in rare cases, the actual
    /// number of samples may be slightly larger than the maximum, because upon reaching EOF, the decoder will drain the codec's
    /// internal buffers which may result in a few additional samples that will be allowed as this is the terminal buffer.
    ///
    func decodeAndScheduleOneBuffer(for session: PlaybackSession, from seekPosition: Double? = nil, immediatePlayback: Bool, maxSampleCount: Int32) {
        
        if eof {return}
        
        // Ask the decoder to decode up to the given number of samples.
        let frameBuffer: FFmpegFrameBuffer = decoder.decode(maxSampleCount: maxSampleCount)

        // Transfer the decoded samples into an audio buffer that the audio engine can schedule for playback.
        if let playbackBuffer = AVAudioPCMBuffer(pcmFormat: playbackCtx.audioFormat, frameCapacity: AVAudioFrameCount(frameBuffer.sampleCount)) {
            
            if frameBuffer.needsFormatConversion {
                sampleConverter.convert(samplesIn: frameBuffer, andCopyTo: playbackBuffer)
                
            } else {
                frameBuffer.copySamples(to: playbackBuffer)
            }

            // Pass off the audio buffer to the audio engine. The completion handler is executed when
            // the buffer has finished playing.
            //
            // Note that:
            //
            // 1 - the completion handler recursively triggers another decoding / scheduling task.
            // 2 - the completion handler will be invoked by a background thread.
            // 3 - the completion handler will execute even when the player is stopped, i.e. the buffer
            //      has not really completed playback but has been removed from the playback queue.

            // TODO: Fix the last 2 parameters ... seek posn not showing correctly.
            playerNode.scheduleBuffer(playbackBuffer, for: session, completionHandler: self.bufferCompletionHandler(session), seekPosition, immediatePlayback)

            // Upon scheduling the buffer, increment the counter.
            scheduledBufferCount.increment()
        }
    }
    
    func bufferCompleted(_ session: PlaybackSession) {
        
        // Audio buffer has completed playback, so decrement the counter.
        self.scheduledBufferCount.decrement()
        
        // If the buffer-associated session is not the same as the current session
        // (possible if stop() was called, eg. old buffers that complete when seeking), don't do anything.
        guard PlaybackSession.isCurrent(session) else {return}
        
        if !self.eof {

            // If EOF has not been reached, continue recursively decoding / scheduling.
            self.decodeAndScheduleOneBufferAsync(for: session, maxSampleCount: playbackCtx.sampleCountForDeferredPlayback)

        } else if self.scheduledBufferCount.isZero {
            
            // EOF has been reached, and all buffers have completed playback.
            // Signal playback completion (on the main thread).

            DispatchQueue.main.async {
                self.trackCompleted(session)
            }
        }
    }
    
    // Signal track playback completion
    func trackCompleted(_ session: PlaybackSession) {
        Messenger.publish(.player_trackPlaybackCompleted, payload: session)
    }
    
    func pause() {
        playerNode.pause()
    }
    
    func resume() {
        playerNode.play()
    }
    
    func stop() {
        
        stopScheduling()
        playerNode.stop()
        decoder?.stop()
    }
    
    func seekToTime(_ session: PlaybackSession, _ seconds: Double, _ beginPlayback: Bool) {
        
        stop()
        
        initiateDecodingAndScheduling(for: session, from: seconds)
        
        if scheduledBufferCount.isPositive {
            
            if beginPlayback {
                playerNode.play()
            }
        }
    }
    
    ///
    /// Cancels all (previously queued) decoding / scheduling operations on the OperationQueue, and blocks until they have been terminated.
    ///
    ///  ```
    ///  After calling this function, we can be assured that no unwanted scheduling will take place asynchronously.
    ///
    ///  This condition is important because ...
    ///
    ///  When seeking, for instance, we would want to first stop any previous scheduling tasks
    ///  that were already executing ... before scheduling new buffers from the new seek position. Otherwise, chunks
    ///  of audio from the previous seek position would suddenly start playing.
    ///
    ///  Similarly, when a file is playing and a new file is suddenly chosen for playback, we would want to stop all
    ///  scheduling for the old file and be sure that only audio from the new file would be scheduled.
    ///  ```
    ///
    func stopScheduling() {
        
        if schedulingOpQueue.operationCount > 0 {
            
            schedulingOpQueue.cancelAllOperations()
            schedulingOpQueue.waitUntilAllOperationsAreFinished()
        }
    }
    
    // Computes a segment completion handler closure, given a playback session.
    func bufferCompletionHandler(_ session: PlaybackSession) -> SessionCompletionHandler {
        
        return {(_ session: PlaybackSession) -> Void in
            self.bufferCompleted(session)
        }
    }
}
