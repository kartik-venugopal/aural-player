import Foundation

///
/// Handles decoding for segment loop playback of non-native tracks.
///
extension FFmpegDecoder {
    
    ///
    /// Decodes up to a given maximum number of samples, stopping at the loop end time if it is reached while decoding.
    ///
    /// - Parameter maxSampleCount: Maximum number of samples to be decoded. When this limit is reached, decoding will end.
    ///
    /// - Parameter loopEndTime: The end time of the segment loop, in seconds. This is the terminal point (timestamp) at which decoding will end.
    ///
    /// - returns: a frame buffer containing the decoded samples, ready to be scheduled for playback.
    ///
    func decodeLoop(maxSampleCount: Int32, loopEndTime: Double) -> FFmpegFrameBuffer {
        
        let audioFormat: FFmpegAudioFormat = FFmpegAudioFormat(sampleRate: codec.sampleRate, channelCount: codec.channelCount,
                                                               channelLayout: codec.channelLayout, sampleFormat: codec.sampleFormat)
        
        // Create a frame buffer with the specified maximum sample count and the codec's sample format for this file.
        let buffer: FFmpegFrameBuffer = FFmpegFrameBuffer(audioFormat: audioFormat, maxSampleCount: maxSampleCount)
        
        // Keep decoding as long as EOF is not reached.
        while !eof {
            
            do {
                
                // Try to obtain a single decoded frame.
                let frame = try nextFrame()
                
                if frame.endTimestampSeconds > loopEndTime {
                    
                    // Have reached the end of the loop, need to truncate this frame so that
                    // no samples after loopEndTime are scheduled.
                    let sampleRate = Double(codec.sampleRate)
                    let truncatedSampleCount = Int32((loopEndTime - frame.startTimestampSeconds) * sampleRate)
                    
                    // Truncate frame, append it to the frame buffer, and break from loop
                    frame.keepFirstNSamples(sampleCount: truncatedSampleCount)
                    buffer.appendTerminalFrames([frame])
                    
                    self._endOfLoop.setValue(true)
                    
                    break
                }
                
                // Try appending the frame to the frame buffer.
                // The frame buffer may reject the new frame if appending it would
                // cause its sample count to exceed the maximum.
                if buffer.appendFrame(frame) {
                    
                    // The buffer accepted the new frame. Remove it from the queue.
                    _ = frameQueue.dequeue()
                    
                } else {
                    
                    // The frame buffer rejected the new frame because it is full. End the loop.
                    break
                }
                
            } catch let packetReadError as PacketReadError {
                
                // If the error signals EOF, suppress it, and simply set the EOF flag.
                self._eof.setValue(packetReadError.isEOF)
                
                // If the error is something other than EOF, it either indicates a real problem or simply that there was one bad packet. Log the error.
                if !eof {NSLog("Packet read error while reading track \(fileCtx.filePath) : \(packetReadError)")}
                
            } catch {
                
                // This either indicates a real problem or simply that there was one bad packet. Log the error.
                NSLog("Decoder error while reading track \(fileCtx.filePath) : \(error)")
            }
        }
        
        // If and when EOF has been reached, drain both:
        //
        // - the frame queue (which may have overflow frames left over from the previous decoding loop), AND
        // - the codec's internal frame buffer
        //
        //, and append them to our frame buffer.
        
        if eof {
            
            self._endOfLoop.setValue(true)
            
            var terminalFrames: [FFmpegFrame] = frameQueue.dequeueAll()
            
            do {
                
                let drainFrames = try codec.drain()
                terminalFrames.append(contentsOf: drainFrames.frames)
                
            } catch {
                NSLog("Decoder drain error while reading track \(fileCtx.filePath): \(error)")
            }
            
            // Append these terminal frames to the frame buffer (the frame buffer cannot reject terminal frames).
            buffer.appendTerminalFrames(terminalFrames)
        }
        
        return buffer
    }
    
    ///
    /// Resets all loop-related state, in response to a loop either being completed or being removed.
    ///
    func loopCompleted() {
        self._endOfLoop.setValue(false)
    }
}
