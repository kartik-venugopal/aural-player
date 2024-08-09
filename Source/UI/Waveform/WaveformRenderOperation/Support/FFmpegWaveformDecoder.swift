//
//  FFmpegWaveformDecoder.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation
import AVFAudio
import AVFoundation

class FFmpegWaveformDecoder {
    
    ///
    /// The maximum difference between a desired seek position and an actual seek
    /// position (that results from actually performing a seek) that will be tolerated,
    /// i.e. will not require a correction.
    ///
    private static let seekPositionTolerance: Double = 0.01

    ///
    /// FFmpeg context for the file that is to be decoded
    ///
    var fileCtx: FFmpegFileContext
    
    ///
    /// The first / best audio stream in this file, if one is present. May be nil.
    ///
    let stream: FFmpegAudioStream
    
    ///
    /// Audio codec chosen by **FFmpeg** to decode this file.
    ///
    let codec: FFmpegAudioCodec
    
    ///
    /// Duration of the track being decoded.
    ///
    var duration: Double {fileCtx.duration}
    
    let chunkSize: Int
    
    /// Number of samples read so far from the designated chunk.
    var samplesReadForChunk: Int32 = 0
    
    /// Whether or not the end of file (EOF) has been reached during reading.
    var eof: Bool = false
    
    ///
    /// A queue data structure used to temporarily hold buffered frames as they are decoded by the codec and before passing them off to a FrameBuffer.
    ///
    /// # Notes #
    ///
    /// During a decoding loop, in the event that a FrameBuffer fills up, this queue will hold the overflow (excess) frames that can be passed off to the next
    /// FrameBuffer in the next decoding loop.
    ///
    let frameQueue: Queue<FFmpegFrame> = Queue<FFmpegFrame>()
    
    let resampleCtx: FFmpegAVAEResamplingContext?
    
    private(set) lazy var audioFormat: FFmpegAudioFormat = FFmpegAudioFormat(sampleRate: codec.sampleRate,
                                                                             channelCount: codec.channelCount,
                                                                             channelLayout: codec.channelLayout,
                                                                             sampleFormat: codec.sampleFormat)
    
    private(set) lazy var channelCount: Int = Int(audioFormat.channelCount)
    
    private(set) lazy var sampleRateDouble: Double = Double(codec.sampleRate)
    
    /// The currently executing ``Operation`` created by this reader.
    private var operation: Operation!
    
    ///
    /// Given ffmpeg context for a file, initializes an appropriate codec to perform decoding.
    ///
    /// - Parameter fileContext: ffmpeg context for the audio file to be decoded by this decoder.
    ///
    /// throws if:
    ///
    /// - No audio stream is found in the file.
    /// - Unable to initialize the required codec.
    ///
    init(for file: URL, chunkSize: Int) throws {
        
        self.fileCtx = try FFmpegFileContext(for: file)
        self.chunkSize = chunkSize
        
        guard let theAudioStream = fileCtx.bestAudioStream else {
            throw FormatContextInitializationError(description: "\nUnable to find audio stream in file: '\(fileCtx.filePath)'")
        }
        
        self.stream = theAudioStream
        self.codec = try FFmpegAudioCodec(fromParameters: stream.avStream.codecpar)
        
        if codec.sampleFormat.needsFormatConversion {
            
            guard let resampleCtx = FFmpegAVAEResamplingContext(inputChannelLayout: codec.channelLayout,
                                                                outputChannelLayout: .init(encapsulating: AVChannelLayout_Stereo),
                                                                sampleRate: Int64(codec.sampleRate),
                                                                inputSampleFormat: codec.sampleFormat.avFormat) else {
                
                throw ResamplerInitializationError(description: "Unable to create a resampling context. Cannot decode file: '\(fileCtx.filePath)'")
            }
            
            self.resampleCtx = resampleCtx
            
        } else {
            self.resampleCtx = nil
        }
    }
    
    ///
    /// Decodes the currently playing file's audio stream to produce a given (maximum) number of samples, in a loop, and returns a frame buffer
    /// containing all the samples produced during the loop.
    ///
    /// - Parameter maxSampleCount: Maximum number of samples to be decoded
    ///
    /// # Notes #
    ///
    /// 1. If the codec reaches EOF during the loop, the number of samples produced may be less than the maximum sample count specified by
    /// the **maxSampleCount** parameter. However, in rare cases, the actual number of samples may be slightly larger than the maximum,
    /// because upon reaching EOF, the decoder will drain the codec's internal buffers which may result in a few additional samples that will be
    /// allowed as this is the terminal buffer.
    ///
    
    func decode(intoBuffer outputBuffer: inout [UnsafeMutablePointer<Float>]) -> Int32 {
        
        // Create a frame buffer with the specified maximum sample count and the codec's sample format for this file.
        let buffer: FFmpegFrameBuffer = FFmpegFrameBuffer(audioFormat: audioFormat, maxSampleCount: Int32(chunkSize))
        
        // Keep decoding as long as EOF is not reached.
        while !eof {
            
            do {
                
                // Try to obtain a single decoded frame.
                let frame = try nextFrame()
                
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
            
            var terminalFrames: [FFmpegFrame] = frameQueue.dequeueAll()
            
            do {
                terminalFrames.append(contentsOf: try codec.drain().frames)
                
            } catch {
                NSLog("Decoder drain error while reading track \(fileCtx.filePath): \(error)")
            }
            
            // Append these terminal frames to the frame buffer (the frame buffer cannot reject terminal frames).
            buffer.appendTerminalFrames(terminalFrames)
        }
        
        transferSamplesToOutputBuffer(from: buffer, intoBuffer: &outputBuffer)
        return buffer.sampleCount
    }
    
    ///
    /// Decodes the next available packet in the stream, if required, to produce a single frame.
    ///
    /// - returns:  A single frame containing PCM samples.
    ///
    /// - throws:   A **PacketReadError** if the next packet in the stream cannot be read, OR
    ///             A **DecoderError** if a packet was read but unable to be decoded by the codec.
    ///
    /// # Notes #
    ///
    /// 1. If there are already frames in the frame queue, that were produced by a previous call to this function, no
    /// packets will be read / decoded. The first frame from the queue will simply be returned.
    ///
    /// 2. If more than one frame is produced by the decoding of a packet, the first such frame will be returned, and any
    /// excess frames will remain in the frame queue to be consumed by the next call to this function.
    ///
    /// 3. The returned frame will not be dequeued (removed from the queue) by this function. It is the responsibility of the caller
    /// to do so, upon consuming the frame.
    ///
    func nextFrame() throws -> FFmpegFrame {
        
        while frameQueue.isEmpty {
        
            guard let packet = try fileCtx.readPacket(from: stream) else {continue}
            
            let frames = try codec.decode(packet: packet).frames
            frames.forEach {frameQueue.enqueue($0)}
        }
        
        return frameQueue.peek()!
    }
}
