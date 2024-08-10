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
import AVFoundation
import Accelerate

class FFmpegWaveformDecoder: WaveformDecoderProtocol {
    
    var file: URL {
        fileCtx.file
    }
    
    var sampleRate: Double {
        Double(stream.sampleRate)
    }
    
    let totalSamples: AVAudioFramePosition
    
    var totalSamplesRead: AVAudioFrameCount = 0
    
    var fileCtx: FFmpegFileContext
    let stream: FFmpegAudioStream
    let codec: FFmpegAudioCodec
    
    /// Whether or not the end of file (EOF) has been reached during reading.
    var reachedEOF: Bool = false
    
    let frameQueue: Queue<FFmpegFrame> = Queue<FFmpegFrame>()
    
    let resampleCtx: FFmpegAVAEResamplingContext?
    
    private(set) lazy var audioFormat: FFmpegAudioFormat = FFmpegAudioFormat(sampleRate: codec.sampleRate,
                                                                             channelCount: codec.channelCount,
                                                                             channelLayout: codec.channelLayout,
                                                                             sampleFormat: codec.sampleFormat)
    
    private(set) lazy var channelCount: AVAudioChannelCount = AVAudioChannelCount(audioFormat.channelCount)
    
    private(set) lazy var sampleRateDouble: Double = Double(codec.sampleRate)
    
    /// The currently executing ``Operation`` created by this reader.
    private var operation: Operation!
    
    init(for file: URL) throws {
        
        self.fileCtx = try FFmpegFileContext(for: file)
        
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
        
        self.totalSamples = AVAudioFramePosition(Double(stream.sampleRate) * fileCtx.duration)
    }
    
    func decode(intoBuffer processingBuffer: inout Float2DBuffer, currentBufferLength: AVAudioFrameCount) throws -> AVAudioFrameCount {
        
        // Create a frame buffer with the specified maximum sample count and the codec's sample format for this file.
        let buffer: FFmpegFrameBuffer = FFmpegFrameBuffer(audioFormat: audioFormat, maxSampleCount: Int32(waveformDecodingChunkSize))
        
        // Keep decoding as long as EOF is not reached.
        while !reachedEOF {
            
            do {
                
                // Try to obtain a single decoded frame.
                let frame = try nextFrame()

                if buffer.appendFrame(frame) {
                    _ = frameQueue.dequeue()
                    
                } else {break}
                
            } catch let packetReadError as PacketReadError {
                
                self.reachedEOF = packetReadError.isEOF
                if !reachedEOF {NSLog("Packet read error while reading track \(fileCtx.filePath) : \(packetReadError)")}
                
            } catch {
                NSLog("Decoder error while reading track \(fileCtx.filePath) : \(error)")
            }
        }
        
        if reachedEOF {
            
            var terminalFrames: [FFmpegFrame] = frameQueue.dequeueAll()
            
            do {
                terminalFrames.append(contentsOf: try codec.drain().frames)
                
            } catch {
                NSLog("Decoder drain error while reading track \(fileCtx.filePath): \(error)")
            }
            
            // Append these terminal frames to the frame buffer (the frame buffer cannot reject terminal frames).
            buffer.appendTerminalFrames(terminalFrames)
        }
        
        transferSamplesToOutputBuffer(from: buffer, intoBuffer: &processingBuffer, currentBufferLength: currentBufferLength)
        
        let samplesRead = AVAudioFrameCount(buffer.sampleCount)
        totalSamplesRead += samplesRead
        
        return samplesRead
    }
    
    func nextFrame() throws -> FFmpegFrame {
        
        while frameQueue.isEmpty {
        
            guard let packet = try fileCtx.readPacket(from: stream) else {continue}
            
            let frames = try codec.decode(packet: packet).frames
            frames.forEach {frameQueue.enqueue($0)}
        }
        
        return frameQueue.peek()!
    }
    
    func transferSamplesToOutputBuffer(from frameBuffer: FFmpegFrameBuffer,
                                       intoBuffer outputBuffer: inout Float2DBuffer,
                                       currentBufferLength: AVAudioFrameCount) {
        
        if frameBuffer.needsFormatConversion {
            convert(samplesIn: frameBuffer, andCopyTo: &outputBuffer, currentBufferLength: currentBufferLength)
            
        } else {
            copy(samplesIn: frameBuffer, intoBuffer: &outputBuffer, currentBufferLength: currentBufferLength)
        }
    }
    
    private func copy(samplesIn frameBuffer: FFmpegFrameBuffer, 
                      intoBuffer outputBuffer: inout Float2DBuffer,
                      currentBufferLength: AVAudioFrameCount) {
        
        // Keeps track of how many samples have been copied over so far.
        // This will be used as an offset when performing each copy operation.
        var sampleCountSoFar: Int = Int(currentBufferLength)
        
        for frame in frameBuffer.frames {
            
            let sampleCount = frame.sampleCount
            let firstSampleIndex = Int(frame.firstSampleIndex)
            
            // NOTE - The following copy operation assumes a non-interleaved output format (i.e. the standard Core Audio format).
            
            // Temporarily bind the input sample buffers as floating point numbers, and perform the copy.
            frame.dataPointers.withMemoryRebound(to: FloatPointer.self, capacity: outputBuffer.count) {srcPointers in
                
                // Iterate through all the channels.
                for channelIndex in 0..<outputBuffer.count {
                    
                    // Use Accelerate to perform the copy optimally, starting at the given offset.
                    cblas_scopy(sampleCount,
                                srcPointers[channelIndex].advanced(by: firstSampleIndex), 1,
                                outputBuffer[channelIndex].advanced(by: sampleCountSoFar), 1)
                }
            }
            
            sampleCountSoFar += frame.intSampleCount
        }
    }
    
    private func convert(samplesIn frameBuffer: FFmpegFrameBuffer, andCopyTo outputBuffer: inout Float2DBuffer, currentBufferLength: AVAudioFrameCount) {
        
        guard let resampleCtx = self.resampleCtx else {return}
        
        let outputChannelCount = outputBuffer.count
        var sampleCountSoFar: Int = Int(currentBufferLength)
        let outputData: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>! = .allocate(capacity: outputChannelCount)
        defer {outputData.deallocate()}
        
        outputBuffer.withUnsafeMutableBufferPointer {unsafeOutputBufferPointers in
            
            unsafeOutputBufferPointers.withMemoryRebound(to: UnsafeMutablePointer<UInt8>.self) {byteBuffer in
                
                // Convert one frame at a time.
                for frame in frameBuffer.frames {
                    
                    let offset = sampleCountSoFar * bytesInAFloat
                    for ch in 0..<outputChannelCount {
                        outputData[ch] = byteBuffer[ch].advanced(by: offset)
                    }
                    
                    resampleCtx.convertFrame(frame, andStoreIn: outputData, outputChannelCount: outputChannelCount)
//                    resampleCtx.convertFrame(frame, andStoreIn: outputData)
                    sampleCountSoFar += frame.intSampleCount
                }
            }
        }
    }
}
