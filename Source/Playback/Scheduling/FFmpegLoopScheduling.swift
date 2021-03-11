import AVFoundation

extension FFmpegScheduler {
    
    // TODO: Test with loops that extend till EOF, very small loops, etc.
    
    var endOfLoop: Bool {decoder.endOfLoop}
    
    func playLoop(_ session: PlaybackSession, _ beginPlayback: Bool = true) {
        
        stop()
        scheduledBufferCounts[session] = AtomicCounter<Int>()
        
        guard let thePlaybackCtx = session.track.playbackContext as? FFmpegPlaybackContext,
            let loop = session.loop, let loopEndTime = loop.endTime else {return}
        
        self.playbackCtx = thePlaybackCtx
        
        print("\nPlaying loop with startTime = \(loop.startTime), endTime = \(loopEndTime)")
        
        initiateLoopDecodingAndScheduling(for: session, with: loop)
        
        // Check that at least one audio buffer was successfully scheduled, before beginning playback.
        if beginPlayback, let bufferCount = scheduledBufferCounts[session], bufferCount.isPositive {
            playerNode.play()
        }
    }
    
    func initiateLoopDecodingAndScheduling(for session: PlaybackSession, with loop: PlaybackLoop, startingAt time: Double? = nil) {
        
        do {
            
            let startTime = time ?? loop.startTime
            
//            print("BEFORE Seek", decoder.eof, decoder.endOfLoop)
            
            // If a seek position was specified, ask the decoder to seek
            // within the stream.
            try decoder.seek(to: startTime)
            
//            print("Seek completed", decoder.eof, decoder.endOfLoop)
            
            // Schedule one buffer for immediate playback
            decodeAndScheduleOneLoopBuffer(for: session, from: startTime, maxSampleCount: playbackCtx.sampleCountForImmediatePlayback)
            
//            print("B1 completed", scheduledBufferCounts[session]!.value, decoder.eof, decoder.endOfLoop)
            
            // Schedule a second buffer asynchronously, for later, to avoid a gap in playback.
            decodeAndScheduleOneLoopBufferAsync(for: session, maxSampleCount: playbackCtx.sampleCountForDeferredPlayback)
            
//            print("B2 completed", scheduledBufferCounts[session]!.value, decoder.eof, decoder.endOfLoop)
            
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
    private func decodeAndScheduleOneLoopBufferAsync(for session: PlaybackSession, maxSampleCount: Int32) {
        
        if endOfLoop {return}
        
        self.schedulingOpQueue.addOperation {
            self.decodeAndScheduleOneLoopBuffer(for: session, maxSampleCount: maxSampleCount)
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
    private func decodeAndScheduleOneLoopBuffer(for session: PlaybackSession, from seekPosition: Double? = nil, maxSampleCount: Int32) {
        
        if endOfLoop {return}
        
        // Ask the decoder to decode up to the given number of samples.
        let frameBuffer: FFmpegFrameBuffer = decoder.decodeLoop(maxSampleCount: maxSampleCount, loopEndTime: session.loop!.endTime!)

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

            playerNode.scheduleBuffer(playbackBuffer, for: session, completionHandler: self.loopBufferCompletionHandler(session), seekPosition, seekPosition != nil)
            
//            let playTime = frameBuffer.sampleCount / frameBuffer.frames[0].sampleRate
//            print("\nScheduled one LOOP buffer with \(frameBuffer.sampleCount) samples equal to \(playTime) seconds")

            // Upon scheduling the buffer, increment the counter.
            scheduledBufferCounts[session]?.increment()
//            print("\nScheduled buffer count now: \(scheduledBufferCounts[session]!.value)")
        }
    }
    
    func loopBufferCompleted(_ session: PlaybackSession) {
        
        // If the buffer-associated session is not the same as the current session
        // (possible if stop() was called, eg. old buffers that complete when seeking), don't do anything.
        guard PlaybackSession.isCurrent(session) else {return}
        
        // Audio buffer has completed playback, so decrement the counter.
        scheduledBufferCounts[session]?.decrement()
        
        if !self.endOfLoop {

            // If EOF has not been reached, continue recursively decoding / scheduling.
            self.decodeAndScheduleOneLoopBufferAsync(for: session, maxSampleCount: playbackCtx.sampleCountForDeferredPlayback)

        } else if let bufferCount = scheduledBufferCounts[session], bufferCount.isZero {
            
            // EOF has been reached, and all buffers have completed playback.
            // Signal playback completion (on the main thread).

            DispatchQueue.main.async {
                self.loopCompleted(session)
            }
        }
    }
    
    func loopCompleted(_ session: PlaybackSession) {
        
        decoder.loopCompleted()
        playLoop(session)
    }
    
    // Computes a segment completion handler closure, given a playback session.
    func loopBufferCompletionHandler(_ session: PlaybackSession) -> SessionCompletionHandler {
        
        return {(_ session: PlaybackSession) -> Void in
            self.loopBufferCompleted(session)
        }
    }
    
    // This function is for seeking within a complete segment loop
    func playLoop(_ session: PlaybackSession, _ playbackStartTime: Double, _ beginPlayback: Bool) {
        
        stop()
        scheduledBufferCounts[session] = AtomicCounter<Int>()
        
        // Reset all the loop state in the decoder
        decoder.loopCompleted()
        
        guard let thePlaybackCtx = session.track.playbackContext as? FFmpegPlaybackContext,
            let loop = session.loop, let loopEndTime = loop.endTime else {return}
        
        self.playbackCtx = thePlaybackCtx
        
        print("\nPlaying loop with startTime = \(loop.startTime), endTime = \(loopEndTime), but starting at: \(playbackStartTime)")
        
        initiateLoopDecodingAndScheduling(for: session, with: loop, startingAt: playbackStartTime)
        
        // Check that at least one audio buffer was successfully scheduled, before beginning playback.
        if beginPlayback, let bufferCount = scheduledBufferCounts[session], bufferCount.isPositive {
            playerNode.play()
        }
    }
    
    func endLoop(_ session: PlaybackSession, _ loopEndTime: Double) {
        
        // TODO: Handle race conditions (if loop completes just before endLoop() is called)
        // If loop completes after endLoop() is called, it's harmless as the PlaybackSession will no longer be current.
        // TODO: Does PlaybackSession need to become thread-safe ???
        decoder.endLoop()

        // Schedule a second buffer, for later, to avoid a gap in playback.
        decodeAndScheduleOneBufferAsync(for: session, maxSampleCount: playbackCtx.sampleCountForDeferredPlayback)
        decodeAndScheduleOneBufferAsync(for: session, maxSampleCount: playbackCtx.sampleCountForDeferredPlayback)
    }
}
