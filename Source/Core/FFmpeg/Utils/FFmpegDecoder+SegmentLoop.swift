//
//  FFmpegLoopDecoding.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation
import AVFoundation

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
    func decodeLoop(maxSampleCount: Int32, loopEndTime: Double, intoFormat outputFormat: AVAudioFormat) -> AVAudioPCMBuffer? {
        
        // Create a frame buffer with the specified maximum sample count and the codec's sample format for this file.
        let buffer: FFmpegFrameBuffer = FFmpegFrameBuffer(audioFormat: audioFormat, maxSampleCount: maxSampleCount)
        
        recurringPacketReadErrorCount = 0
        
        // Keep decoding as long as EOF is not reached.
        while !eof {
            
            do {
                
                // Try to obtain a single decoded frame.
                let frame = try nextFrame()
                
                // Reset the counter because packet read succeeded.
                recurringPacketReadErrorCount = 0
                
                if frame.endTimestampSeconds > loopEndTime {
                    
                    // Have reached the end of the loop, need to truncate this frame so that
                    // no samples after loopEndTime are scheduled.
                    let truncatedSampleCount = Int32((loopEndTime - frame.startTimestampSeconds) * sampleRateDouble)
                    
                    // Truncate frame, append it to the frame buffer, and break from loop
                    frame.keepFirstNSamples(sampleCount: truncatedSampleCount)
                    buffer.appendTerminalFrames([frame])
                    
                    self._endOfLoop.setTrue()
                    
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
                
            } catch {
                
                if let packetReadError = error as? PacketReadError {
                    
                    // If the error signals EOF, suppress it, and simply set the EOF flag.
                    self._eof.setValue(packetReadError.isEOF)
                }
                
                if !eof {
                    
                    NSLog("Decoder error while reading track \(fileCtx.filePath) : \(error)")
                    recurringPacketReadErrorCount.increment()
                    
                    if recurringPacketReadErrorCount == Self.maxConsecutiveIOErrors {
                        
                        _fatalError.setTrue()
                        return nil
                    }
                }
            }
        }
        
        // If and when EOF has been reached, drain both:
        //
        // - the frame queue (which may have overflow frames left over from the previous decoding loop), AND
        // - the codec's internal frame buffer
        //
        //, and append them to our frame buffer.
        
        if eof {
            
            self._endOfLoop.setTrue()
            
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
        
        return transferSamplesToPCMBuffer(from: buffer, outputFormat: outputFormat)
    }
    
    ///
    /// Resets all loop-related state, in response to a loop either being completed or being removed.
    ///
    func loopCompleted() {
        self._endOfLoop.setFalse()
    }
}
