//
//  FFmpegWaveformDecoder+Transfer.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AVFoundation
import Accelerate

extension FFmpegWaveformDecoder {
    
    ///
    /// Transfer the decoded samples into an audio buffer that the audio engine can schedule for playback.
    ///
    func transferSamplesToOutputBuffer(from frameBuffer: FFmpegFrameBuffer, intoBuffer outputBuffer: inout [UnsafeMutablePointer<Float>]) {
        
        if frameBuffer.needsFormatConversion {
            convert(samplesIn: frameBuffer, andCopyTo: &outputBuffer)
            
        } else {
            copy(samplesIn: frameBuffer, intoBuffer: &outputBuffer)
        }
    }
    
    private func copy(samplesIn frameBuffer: FFmpegFrameBuffer, intoBuffer outputBuffer: inout [UnsafeMutablePointer<Float>]) {
        
        // Keeps track of how many samples have been copied over so far.
        // This will be used as an offset when performing each copy operation.
        var sampleCountSoFar: Int = 0
        
        for frame in frameBuffer.frames {
            
            let sampleCount = frame.sampleCount
            let firstSampleIndex = Int(frame.firstSampleIndex)
            
            // NOTE - The following copy operation assumes a non-interleaved output format (i.e. the standard Core Audio format).
            
            // Temporarily bind the input sample buffers as floating point numbers, and perform the copy.
            frame.dataPointers.withMemoryRebound(to: UnsafeMutablePointer<Float>.self, capacity: outputBuffer.count) {srcPointers in
                
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
    
    private func convert(samplesIn frameBuffer: FFmpegFrameBuffer, andCopyTo outputBuffer: inout [UnsafeMutablePointer<Float>]) {
        
        guard let resampleCtx = self.resampleCtx else {return}
        
        let outputChannelCount = outputBuffer.count
        
        var sampleCountSoFar: Int = 0
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

