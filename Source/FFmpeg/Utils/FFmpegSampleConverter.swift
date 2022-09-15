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
import Accelerate

///
/// Performs conversion of PCM audio samples to the standard format suitable for playback in an **AVAudioEngine**,
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
    
    /// See **SampleConverterProtocol.convert()**.
    func convert(samplesIn frameBuffer: FFmpegFrameBuffer, andCopyTo audioBuffer: AVAudioPCMBuffer) {
        
        // --------------------- Step 1: Allocate space for the conversion ---------------------
        
        let audioFormat: FFmpegAudioFormat = frameBuffer.audioFormat
        allocateFor(channelCount: audioFormat.channelCount, sampleCount: frameBuffer.maxFrameSampleCount)
        
        // --------------------- Step 2: Create a context and set options for the conversion ---------------------
        
        // Allocate the context used to perform the conversion.
        guard let resampleCtx = FFmpegAVAEResamplingContext(channelLayout: audioFormat.channelLayout,
                                                            sampleRate: Int64(audioFormat.sampleRate),
                                                            inputSampleFormat: audioFormat.avSampleFormat) else {
            
            NSLog("Unable to create a resampling context. Aborting sample conversion.")
            return
        }
        
        // --------------------- Step 3: Perform the conversion (and copy), frame by frame ---------------------
        
        var sampleCountSoFar: Int = 0
        
        // Convert one frame at a time.
        for frame in frameBuffer.frames {
            
            resampleCtx.convertFrame(frame, andStoreIn: outputData)
            audioBuffer.copy(frame: frame, from: outputData, startOffset: sampleCountSoFar)
            sampleCountSoFar += frame.intSampleCount
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
        guard channelCount > allocatedChannelCount || sampleCount > allocatedSampleCount else {return}
        
        // Not enough space already allocated. Need to re-allocate space.
        
        // First, deallocate any previously allocated space, if required.
        deallocate()
        
        // Allocate space.
        av_samples_alloc(outputData, nil, channelCount, sampleCount, Self.standardSampleFormat, 0)
        
        // Update these variables to keep track of allocated space.
        self.allocatedChannelCount = channelCount
        self.allocatedSampleCount = sampleCount
    }
    
    ///
    /// Deallocates any space previously allocated to hold the converter's output samples.
    ///
    func deallocate() {
        
        guard allocatedChannelCount > 0 && allocatedSampleCount > 0 else {return}
        
        av_freep(&outputData[0])
        
        self.allocatedChannelCount = 0
        self.allocatedSampleCount = 0
    }
}
