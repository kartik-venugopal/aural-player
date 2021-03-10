//import AVFoundation
//import Accelerate
//
/////
///// An AVFoundation implementation of **SampleConverterProtocol**.
/////
///// Uses **AVAudioConverter** to do the actual conversion.
/////
//class AVFSampleConverter: SampleConverterProtocol {
//    
//    /// All the supported input sample formats (16-bit signed or unsigned, 32-bit signed or unsigned, and 32-bit floating point interleaved).
//    private let supportedFormats: [AVSampleFormat] = [AV_SAMPLE_FMT_S16, AV_SAMPLE_FMT_S16P, AV_SAMPLE_FMT_S32, AV_SAMPLE_FMT_S32P, AV_SAMPLE_FMT_FLT]
//    
//    /// See **SampleConverterProtocol.supports()**.
//    func supports(inputFormat: FFmpegAudioFormat) -> Bool {
//        return supportedFormats.contains(inputFormat.avSampleFormat)
//    }
//    
//    /// See **SampleConverterProtocol.convert()**.
//    func convert(samplesIn frameBuffer: FFmpegFrameBuffer, andCopyTo audioBuffer: AVAudioPCMBuffer) {
//        
//        // ----------- Step 1: Create a (temporary) input buffer to hold the unconverted PCM samples. -----------------
//        
//        guard let inputFormat = AVAudioFormat(from: frameBuffer.audioFormat),
//            let converter = AVAudioConverter(from: inputFormat, to: audioBuffer.format) else {return}
//        
//        let frameLength = AVAudioFrameCount(frameBuffer.sampleCount)
//        guard let inputBuffer = AVAudioPCMBuffer(pcmFormat: inputFormat, frameCapacity: frameLength) else {return}
//        inputBuffer.frameLength = frameLength
//        
//        // ----------- Step 2: Copy the unconverted PCM samples to the input buffer. -----------------
//        
//        switch frameBuffer.audioFormat.avSampleFormat {
//            
//        case AV_SAMPLE_FMT_S16:
//            
//            copySamples(in: frameBuffer, ofType: Int16.self, to: inputBuffer.int16ChannelData)
//            
//        case AV_SAMPLE_FMT_S16P:
//            
//            copySamples(in: frameBuffer, ofType: Int16.self, to: inputBuffer.int16ChannelData)
//            
//        case AV_SAMPLE_FMT_S32:
//            
//            copySamples(in: frameBuffer, ofType: Int32.self, to: inputBuffer.int32ChannelData)
//            
//        case AV_SAMPLE_FMT_S32P:
//            
//            copySamples(in: frameBuffer, ofType: Int32.self, to: inputBuffer.int32ChannelData)
//            
//        case AV_SAMPLE_FMT_FLT:
//            
//            copySamples(in: frameBuffer, ofType: Float.self, to: inputBuffer.floatChannelData)
//            
//        default:
//            
//            return
//        }
//        
//        // ----------- Step 3: Perform the format conversion. ----------------------------------------
//        
//        do {
//            
//            try converter.convert(to: audioBuffer, from: inputBuffer)
//            
//        } catch {
//            print("\nConversion failed: \(error)")
//        }
//        
//        audioBuffer.frameLength = frameLength
//    }
//    
//    ///
//    /// A helper function that copies all samples in a frame buffer to a destination buffer.
//    ///
//    /// - Parameter frameBuffer:    The buffer containing source samples for the format conversion.
//    ///
//    /// - Parameter ofType:         The numeric type of the samples, eg. Int16 or Float.
//    ///
//    /// - Parameter destBuffer:     Pointer to a destination buffer.
//    ///
//    private func copySamples<T>(in frameBuffer: FFmpegFrameBuffer, ofType: T.Type, to destBuffer: UnsafePointer<UnsafeMutablePointer<T>>?) where T: SignedNumeric {
//        
//        // Keeps track of how many samples have been copied over so far.
//        var sampleCountSoFar: Int = 0
//        
//        let channelCount: Int = Int(frameBuffer.audioFormat.channelCount)
//        let isInterleaved: Bool = frameBuffer.audioFormat.isInterleaved
//        
//        // The stride is used when samples are interleaved (equals the channel count).
//        let stride: Int = isInterleaved ? channelCount : 1
//        
//        // Memory footprint of type T, in bytes
//        let sizeOfEachSample: Int = MemoryLayout<T>.size
//        
//        // Pre-computed product of stride and size per sample.
//        // NOTE - For interleaved formats, this gives the number of bytes per sample, for all channels.
//        let strideTimesSizeOfEachSample: Int = stride * sizeOfEachSample
//        
//        for frame in frameBuffer.frames {
//            
//            let intSampleCount: Int = Int(frame.sampleCount)
//            let intFirstSampleIndex: Int = Int(frame.firstSampleIndex)
//            
//            for channelIndex in 0..<channelCount {
//                
//                // Get the pointers to the source and destination buffers for the copy operation.
//                guard let srcBytesForChannel = frame.dataPointers[channelIndex],
//                let destBufferChannel = destBuffer?[channelIndex] else {break}
//                
//                _ = srcBytesForChannel.withMemoryRebound(to: T.self, capacity: intSampleCount * stride) {
//                    (srcIntsForChannel: UnsafeMutablePointer<T>) in
//                    
//                    // Use sampleCountSoFar as an offset to determine the starting location for the copy.
//                    memcpy(destBufferChannel.advanced(by: sampleCountSoFar * stride), srcIntsForChannel.advanced(by: intFirstSampleIndex * stride),
//                           intSampleCount * strideTimesSizeOfEachSample)
//                }
//            }
//            
//            sampleCountSoFar += intSampleCount
//        }
//    }
//}
