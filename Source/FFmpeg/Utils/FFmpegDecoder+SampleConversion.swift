//
//  FFmpegSampleConverter.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

fileprivate let bytesInAFloat: Int = MemoryLayout<Float>.size / MemoryLayout<UInt8>.size

///
/// Performs conversion of PCM audio samples to the standard format suitable for playback in an **AVAudioEngine**,
/// i.e. 32-bit floating point non-interleaved (aka planar).
///
/// Uses **libswresample** to do the actual conversion.
///
extension FFmpegDecoder {
    
    func convert(samplesIn frameBuffer: FFmpegFrameBuffer, andCopyTo audioBuffer: AVAudioPCMBuffer) {
        
        let audioFormat: FFmpegAudioFormat = frameBuffer.audioFormat
        
        guard let resampleCtx = self.resampleCtx, let floatChannelData = audioBuffer.floatChannelData else {return}
        
        var sampleCountSoFar: Int = 0
        let channelCount: Int = Int(audioFormat.channelCount)
        let outputData: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>! = .allocate(capacity: channelCount)
        defer {outputData.deallocate()}
        
        floatChannelData.withMemoryRebound(to: UnsafeMutablePointer<UInt8>.self, capacity: channelCount) {outChannelPointers in
            
            // Convert one frame at a time.
            for frame in frameBuffer.frames {
                
                for ch in 0..<channelCount {
                    outputData[ch] = outChannelPointers[ch].advanced(by: sampleCountSoFar * bytesInAFloat)
                }
                
                resampleCtx.convertFrame(frame, andStoreIn: outputData)
                sampleCountSoFar += frame.intSampleCount
            }
        }
        
        audioBuffer.frameLength = AVAudioFrameCount(frameBuffer.sampleCount)
    }
}
