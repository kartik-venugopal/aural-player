import AVFoundation
import Accelerate

///
/// Performs conversion of PCM audio samples to the standard format suitable for playback in an AVAudioEngine,
/// i.e. 32-bit floating point non-interleaved (aka planar).
///
/// Uses **libswresample** to do the actual conversion.
///
class FFmpegSampleConverter {
    
    ///
    /// The standard (i.e. "canonical") audio sample format preferred by Core Audio on macOS.
    /// All our samples scheduled for playback with AVAudioEngine must be in this format.
    ///
    /// Source: https://developer.apple.com/library/archive/documentation/MusicAudio/Conceptual/CoreAudioOverview/CoreAudioEssentials/CoreAudioEssentials.html#//apple_ref/doc/uid/TP40003577-CH10-SW16
    ///
    private static let standardSampleFormat: AVSampleFormat = AV_SAMPLE_FMT_FLTP
    
    ///
    /// Pointers to the memory space allocated for the converter's output samples. Each pointer points to
    /// space allocated to samples for a single channel / plane.
    ///
    var outputData: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>!
    
    ///
    /// Keeps track of the number of channels of output data for which memory space has been allocated.
    ///
    var allocatedChannelCount: Int32 = 0
    
    ///
    /// Keeps track of the number of samples (per channel) of output data for which memory space has been allocated.
    ///
    var allocatedSampleCount: Int32 = 0
    
    init() {
        
        // Allocate space for up to 8 channels of sample data.
        outputData = UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>.allocate(capacity: 8)
        outputData.initialize(to: nil)
    }
    
    /// See **SampleConverterProtocol.supports()**.
    func supports(inputFormat: FFmpegAudioFormat) -> Bool {
        return true     // FFmpeg can handle all relevant format conversions.
    }
    
    /// See **SampleConverterProtocol.convert()**.
    func convert(samplesIn frameBuffer: FFmpegFrameBuffer, andCopyTo audioBuffer: AVAudioPCMBuffer) {
        
        // --------------------- Step 1: Allocate space for the conversion ---------------------
        
        let audioFormat: FFmpegAudioFormat = frameBuffer.audioFormat
        allocateFor(channelCount: audioFormat.channelCount, sampleCount: frameBuffer.maxFrameSampleCount)
        
        // --------------------- Step 2: Create a context and set options for the conversion ---------------------
        
        var sampleCountSoFar: Int = 0
        let channelCount: Int = Int(audioFormat.channelCount)
        let channelLayout: Int64 = audioFormat.channelLayout
        let sampleRate: Int64 = Int64(audioFormat.sampleRate)
        
        // Allocate the context used to perform the conversion.
        // TODO: Throw an error from here ???
        guard let resampleCtx = FFmpegResamplingContext() else {return}
        
        // Set the input / output channel layouts as options prior to resampling.
        // NOTE - Our output channel layout will be the same as that of the input, since we don't
        // need to do any upmixing / downmixing here.
        
        resampleCtx.inputChannelLayout = channelLayout
        resampleCtx.outputChannelLayout = channelLayout
        
        // Set the input / output sample rates as options prior to resampling.
        // NOTE - Our output sample rate will be the same as that of the input, since we don't
        // need to do any upsampling / downsampling here.
        
        resampleCtx.inputSampleRate = sampleRate
        resampleCtx.outputSampleRate = sampleRate
        
        // Set the input / output sample formats as options prior to resampling.
        // NOTE - Our input sample format will be the format of the audio file being played,
        // and our output sample format will always be 32-bit floating point non-interleaved (aka planar).
        
        resampleCtx.inputSampleFormat = audioFormat.sampleFormat.avFormat
        resampleCtx.outputSampleFormat = Self.standardSampleFormat
        
        // --------------------- Step 3: Perform the conversion (and copy), frame by frame ---------------------
        
        resampleCtx.initialize()
        
        // Get a pointer to the audio buffer's internal data buffer.
        guard let audioBufferChannels = audioBuffer.floatChannelData else {return}
        
        // Convert one frame at a time.
        for frame in frameBuffer.frames {
            
            // Access the input data as pointers from the frame being resampled.
            frame.dataPointers.withMemoryRebound(to: UnsafePointer<UInt8>?.self, capacity: channelCount) {
                
                (inputDataPointer: UnsafeMutablePointer<UnsafePointer<UInt8>?>) in
                
                resampleCtx.convert(inputDataPointer: inputDataPointer,
                                    inputSampleCount: frame.sampleCount,
                                    outputDataPointer: outputData,
                                    outputSampleCount: frame.sampleCount)
            }
            
            // Finally, copy the output samples to the given audio buffer.
            
            let intSampleCount: Int = Int(frame.sampleCount)
            let intFirstSampleIndex: Int = Int(frame.firstSampleIndex)
            
            // NOTE - The following copy operation assumes a non-interleaved output format (i.e. the standard Core Audio format).
            
            // Iterate through all the channels.
            for channelIndex in 0..<channelCount {
                
                // Obtain pointers to the input and output data.
                guard let bytesForChannel = outputData[channelIndex] else {break}
                let audioBufferChannel = audioBufferChannels[channelIndex]
                
                // Temporarily bind the output sample buffers as floating point numbers, and perform the copy.
                bytesForChannel.withMemoryRebound(to: Float.self, capacity: intSampleCount) {
                    (outputDataPointer: UnsafeMutablePointer<Float>) in
                    
                    // Use Accelerate to perform the copy optimally, starting at the given offset.
                    cblas_scopy(frame.sampleCount, outputDataPointer.advanced(by: intFirstSampleIndex), 1, audioBufferChannel.advanced(by: sampleCountSoFar), 1)
                }
            }
            
            sampleCountSoFar += intSampleCount
        }
        
        audioBuffer.frameLength = AVAudioFrameCount(frameBuffer.sampleCount)
        deallocate()
    }
    
    ///
    /// Allocates enough memory space for a format conversion that produces output
    /// having a given channel count and sample count.
    ///
    /// - Parameter channelCount:   The number of channels to allocate space for (i.e. the number of output buffers).
    ///
    /// - Parameter sampleCount:   The number of output samples to allocate space for (i.e. the size of each output buffer).
    ///
    /// # Note #
    ///
    /// This function will only perform an allocation if the currently allocated space, if any, is
    /// not enough to accommodate output samples of the given channel and sample counts.
    /// If there is already enough space allocated, nothing will be done.
    ///
    func allocateFor(channelCount: Int32, sampleCount: Int32) {
        
        // Check if we already have enough allocated space for the given
        // channel count and sample count.
        if channelCount > allocatedChannelCount || sampleCount > allocatedSampleCount {
            
            // Not enough space already allocated. Need to re-allocate space.
            
            // First, deallocate any previously allocated space, if required.
            deallocate()
            
            // Allocate space.
            av_samples_alloc(outputData, nil, channelCount, sampleCount, Self.standardSampleFormat, 0)
            
            // Update these variables to keep track of allocated space.
            self.allocatedChannelCount = channelCount
            self.allocatedSampleCount = sampleCount
        }
    }
    
    ///
    /// Deallocates any space previously allocated to hold the converter's output samples.
    ///
    func deallocate() {
        
        if allocatedChannelCount > 0 && allocatedSampleCount > 0 {
            
            av_freep(&outputData[0])
            
            self.allocatedChannelCount = 0
            self.allocatedSampleCount = 0
        }
    }
}
