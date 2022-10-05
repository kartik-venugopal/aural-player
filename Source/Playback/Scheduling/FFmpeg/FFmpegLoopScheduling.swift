//
//  FFmpegLoopScheduling.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

///
/// Handles scheduling of segment loops for non-native tracks using **FFmpeg** to perform decoding.
///
extension FFmpegScheduler {
    
    func playLoop(_ session: PlaybackSession, _ beginPlayback: Bool = true) {
        
        guard let thePlaybackCtx = session.track.playbackContext as? FFmpegPlaybackContext,
              let decoder = thePlaybackCtx.decoder,
              let loop = session.loop else {return}
        
        stop()
        scheduledBufferCounts[session] = AtomicCounter()
        
        // Reset all the loop state in the decoder
        decoder.loopCompleted()
        decoder.framesNeedTimestamps.setValue(true)
        
        initiateLoopDecodingAndScheduling(for: session, context: thePlaybackCtx, decoder: decoder, with: loop)
        
        // Check that at least one audio buffer was successfully scheduled, before beginning playback.
        if beginPlayback, let bufferCount = scheduledBufferCounts[session], bufferCount.isPositive {
            playerNode.play()
        }
        
        messenger.publish(.player_loopRestarted)
    }
    
    func initiateLoopDecodingAndScheduling(for session: PlaybackSession, context: FFmpegPlaybackContext, decoder: FFmpegDecoder, with loop: PlaybackLoop, startingAt time: Double? = nil) {
        
        do {
            
            let startTime = time ?? loop.startTime
            
            // If a seek position was specified, ask the decoder to seek
            // within the stream.
            try decoder.seek(to: startTime)
            
            // Schedule one buffer for immediate playback
            decodeAndScheduleOneLoopBuffer(for: session, context: context, decoder: decoder, from: startTime, maxSampleCount: context.sampleCountForImmediatePlayback)
            
            // Schedule a second buffer asynchronously, for later, to avoid a gap in playback.
            decodeAndScheduleOneLoopBufferAsync(for: session, context: context, decoder: decoder, maxSampleCount: context.sampleCountForDeferredPlayback)
            
        } catch {
            NSLog("Decoder error while reading track \(session.track.displayName) : \(error)")
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
    private func decodeAndScheduleOneLoopBufferAsync(for session: PlaybackSession, context: FFmpegPlaybackContext, decoder: FFmpegDecoder, maxSampleCount: Int32) {
        
        if decoder.endOfLoop {return}
        
        self.schedulingOpQueue.addOperation {
            self.decodeAndScheduleOneLoopBuffer(for: session, context: context, decoder: decoder, maxSampleCount: maxSampleCount)
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
    private func decodeAndScheduleOneLoopBuffer(for session: PlaybackSession, context: FFmpegPlaybackContext, decoder: FFmpegDecoder, from seekPosition: Double? = nil, maxSampleCount: Int32) {
        
        guard !decoder.endOfLoop, let loopEndTime = session.loop?.endTime else {return}
        
        // Ask the decoder to decode up to the given number of samples.
        guard let playbackBuffer = decoder.decodeLoop(maxSampleCount: maxSampleCount, loopEndTime: loopEndTime, intoFormat: context.audioFormat) else {return}
        
        // Pass off the audio buffer to the audio engine. The completion handler is executed when
        // the buffer has finished playing.
        //
        // Note that:
        //
        // 1 - the completion handler recursively triggers another decoding / scheduling task.
        // 2 - the completion handler will be invoked by a background thread.
        // 3 - the completion handler will execute even when the player is stopped, i.e. the buffer
        //      has not really completed playback but has been removed from the playback queue.
        
        playerNode.scheduleBuffer(playbackBuffer, for: session, completionHandler: self.loopBufferCompletionHandler(session),
                                  seekPosition, seekPosition != nil)
        
        // Upon scheduling the buffer, increment the counter.
        scheduledBufferCounts[session]?.increment()
    }
    
    func loopBufferCompleted(_ session: PlaybackSession) {
        
        // If the buffer-associated session is not the same as the current session
        // (possible if stop() was called, eg. old buffers that complete when seeking), don't do anything.
        guard PlaybackSession.isCurrent(session), let playbackCtx = session.track.playbackContext as? FFmpegPlaybackContext,
              let decoder = playbackCtx.decoder else {return}
        
        // Audio buffer has completed playback, so decrement the counter.
        scheduledBufferCounts[session]?.decrement()
        
        if !decoder.endOfLoop {

            // If EOF has not been reached, continue recursively decoding / scheduling.
            self.decodeAndScheduleOneLoopBufferAsync(for: session, context: playbackCtx, decoder: decoder,
                                                     maxSampleCount: playbackCtx.sampleCountForDeferredPlayback)

        } else if let bufferCount = scheduledBufferCounts[session], bufferCount.isZero {
            
            // EOF has been reached, and all buffers have completed playback.
            // Signal playback completion (on the main thread).

            DispatchQueue.main.async {
                
                decoder.loopCompleted()
                self.playLoop(session)
            }
        }
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
        scheduledBufferCounts[session] = AtomicCounter()
        
        guard let thePlaybackCtx = session.track.playbackContext as? FFmpegPlaybackContext,
              let decoder = thePlaybackCtx.decoder,
              let loop = session.loop else {return}
        
        // Reset all the loop state in the decoder
        decoder.loopCompleted()
        decoder.framesNeedTimestamps.setValue(true)
        
        initiateLoopDecodingAndScheduling(for: session, context: thePlaybackCtx, decoder: decoder, with: loop, startingAt: playbackStartTime)
        
        // Check that at least one audio buffer was successfully scheduled, before beginning playback.
        if beginPlayback, let bufferCount = scheduledBufferCounts[session], bufferCount.isPositive {
            playerNode.play()
        }
    }
    
    func endLoop(_ session: PlaybackSession, _ loopEndTime: Double, _ beginPlayback: Bool) {
        
        guard let decoder = (session.track.playbackContext as? FFmpegPlaybackContext)?.decoder else {return}
        
        // Mark the player's current seek position. We will resume playback from this position.
        let seekPosition = playerNode.seekPosition

        // There should be no loop scheduling going on at this point.
        // Cancel pending tasks, wait, and reset all loop state, before proceeding.
        stop()
        decoder.loopCompleted()
        
        // Now, seek to the position marked earlier, to resume playback.
        seekToTime(session, seekPosition, beginPlayback)
    }
}
