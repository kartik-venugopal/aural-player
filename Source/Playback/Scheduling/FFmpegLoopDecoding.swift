import Foundation

extension FFmpegDecoder {
    
    func decodeLoop(maxSampleCount: Int32, loopEndTime: Double) -> FFmpegFrameBuffer {
        
//        print("decodeLoop(): maxSampleCount = \(maxSampleCount), loopEndTime = \(loopEndTime)")
        
        let audioFormat: FFmpegAudioFormat = FFmpegAudioFormat(sampleRate: codec.sampleRate, channelCount: codec.channelCount,
                                                               channelLayout: codec.channelLayout, sampleFormat: codec.sampleFormat)
        
        // Create a frame buffer with the specified maximum sample count and the codec's sample format for this file.
        let buffer: FFmpegFrameBuffer = FFmpegFrameBuffer(audioFormat: audioFormat, maxSampleCount: maxSampleCount)
        
        let sampleRate = Double(codec.sampleRate)
        
        // Keep decoding as long as EOF is not reached.
        while !eof {
            
            do {
                
                // Try to obtain a single decoded frame.
                let frame = try nextFrame()
                
                // TODO: All frames won't have PTS (if packet has multiple frames, eg. APE)
                let frameStartTime = Double(frame.pts) * stream.timeBase.ratio
                let frameEndTime = frameStartTime + (Double(frame.sampleCount) / sampleRate)
                
//                print("frameStartTime = \(frameStartTime), frameEndTime = \(frameEndTime)")
                
                if loopEndTime < frameEndTime {
                    
//                    print("BREAK !!! loopEndTime = \(loopEndTime), frameEndTime = \(frameEndTime)")
                    
                    let truncatedSampleCount = Int32((loopEndTime - frameStartTime) * sampleRate)
                    
                    // Truncate frame, append it to the frame buffer, and break from loop
                    frame.keepFirstNSamples(sampleCount: truncatedSampleCount)
                    buffer.appendTerminalFrames([frame])
                    
                    self.endOfLoop.setValue(true)
                    
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
                self.eof = packetReadError.isEOF
                
                // If the error is something other than EOF, it either indicates a real problem or simply that there was one bad packet. Log the error.
                if !eof {print("\nPacket read error:", packetReadError)}
                
            } catch {
                
                // This either indicates a real problem or simply that there was one bad packet. Log the error.
                print("\nDecoder error:", error)
            }
        }
        
        // If and when EOF has been reached, drain both:
        //
        // - the frame queue (which may have overflow frames left over from the previous decoding loop), AND
        // - the codec's internal frame buffer
        //
        //, and append them to our frame buffer.
        
        if eof {
            
            self.endOfLoop.setValue(true)
            
            var terminalFrames: [FFmpegFrame] = frameQueue.dequeueAll()
            
            do {
                
                let drainFrames = try codec.drain()
                terminalFrames.append(contentsOf: drainFrames.frames)
                
            } catch {
                print("\nDecoder drain error:", error)
            }
            
            // Append these terminal frames to the frame buffer (the frame buffer cannot reject terminal frames).
            buffer.appendTerminalFrames(terminalFrames)
        }
        
        return buffer
    }
    
    func loopCompleted() {
        self.endOfLoop.setValue(false)
    }
}
