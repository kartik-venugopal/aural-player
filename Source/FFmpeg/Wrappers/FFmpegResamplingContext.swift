//
//  FFmpegResamplingContext.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A wrapper around an ffmpeg **SwrContext** that performs a resampling conversion:
///
/// A resampling conversion could consist of any or all of the following:
///
/// - Conversion of channel layout (re-matrixing)
/// - Conversion of sample rate (upsampling / downsampling)
/// - Conversion of sample format
///
class FFmpegResamplingContext {

    ///
    /// Pointer to the encapsulated SwrContext struct.
    ///
    fileprivate var resampleCtx: OpaquePointer?
    
    ///
    /// An UnsafeMutableRawPointer to **resampleCtx**.
    ///
    private let rawPointer: UnsafeMutableRawPointer?
    
    ///
    /// Tries to allocate a resampling context. Returns nil if the allocation fails.
    ///
    init?() {
        
        // Allocate memory for the context.
        self.resampleCtx = swr_alloc()
        
        // Check if memory allocation was successful. Can't proceed otherwise.
        guard resampleCtx != nil else {
            
            NSLog("Unable to allocate memory for resampling context.")
            return nil
        }
        
        self.rawPointer = UnsafeMutableRawPointer(resampleCtx)
    }
    
    ///
    /// The channel layout of the input samples.
    ///
    var inputChannelLayout: Int64? {
        
        didSet {
            
            if let channelLayout = inputChannelLayout {
                av_opt_set_channel_layout(rawPointer, "in_channel_layout", channelLayout, 0)
            }
        }
    }
    
    ///
    /// The (desired) channel layout of the output samples.
    ///
    var outputChannelLayout: Int64? {
        
        didSet {
            
            if let channelLayout = outputChannelLayout {
                av_opt_set_channel_layout(rawPointer, "out_channel_layout", channelLayout, 0)
            }
        }
    }
    
    ///
    /// The sample rate of the input samples.
    ///
    var inputSampleRate: Int64? {
        
        didSet {
            
            if let sampleRate = inputSampleRate {
                av_opt_set_int(rawPointer, "in_sample_rate", sampleRate, 0)
            }
        }
    }
    
    ///
    /// The (desired) sample rate of the output samples.
    ///
    var outputSampleRate: Int64? {
        
        didSet {
            
            if let sampleRate = outputSampleRate {
                av_opt_set_int(rawPointer, "out_sample_rate", sampleRate, 0)
            }
        }
    }
    
    ///
    /// The sample format of the input samples.
    ///
    var inputSampleFormat: AVSampleFormat? {
        
        didSet {
            
            if let sampleFormat = inputSampleFormat {
                av_opt_set_sample_fmt(rawPointer, "in_sample_fmt", sampleFormat, 0)
            }
        }
    }
    
    ///
    /// The (desired) sample format of the output samples.
    ///
    var outputSampleFormat: AVSampleFormat? {
        
        didSet {
            
            if let sampleFormat = outputSampleFormat {
                av_opt_set_sample_fmt(rawPointer, "out_sample_fmt", sampleFormat, 0)
            }
        }
    }
    
    ///
    /// Initializes this context.
    ///
    /// ```
    /// Must be called:
    /// **after** setting all options (eg. channel layout, sample rate), and
    /// **before** performing a conversion (i.e. calling **convert()**)
    /// ```
    ///
    func initialize() {
        swr_init(resampleCtx)
    }
    
    ///
    /// Performs the resampling conversion.
    ///
    /// # Important #
    ///
    /// This function does *not* allocate space for output samples. It is the caller's responsibility to do so
    /// before invoking **convert()**.
    ///
    /// - Parameter inputDataPointer: Pointer to the input data (as bytes).
    ///
    /// - Parameter inputSampleCount: The number of input samples (per channel).
    ///
    /// - Parameter outputDataPointer: Pointer to the allocated space for the output data (as bytes).
    ///
    /// - Parameter outputSampleCount: The number of (desired) output samples (per channel).
    ///
    @inline(__always)
    func convert(inputDataPointer: UnsafeMutablePointer<UnsafePointer<UInt8>?>?,
                 inputSampleCount: Int32,
                 outputDataPointer: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>,
                 outputSampleCount: Int32) {

        swr_convert(resampleCtx, outputDataPointer, outputSampleCount, inputDataPointer, inputSampleCount)
    }

    /// Frees the context.
    deinit {
        swr_free(&resampleCtx)
    }
}

///
/// Special case for conversion to the Canonical **CoreAudio** format for **AVAudioEngine** playback.
///
class FFmpegAVAEResamplingContext: FFmpegResamplingContext {
    
    ///
    /// The standard (i.e. "canonical") audio sample format preferred by Core Audio on macOS.
    /// All our samples scheduled for playback with AVAudioEngine must be in this format.
    ///
    /// Source: https://developer.apple.com/library/archive/documentation/MusicAudio/Conceptual/CoreAudioOverview/CoreAudioEssentials/CoreAudioEssentials.html#//apple_ref/doc/uid/TP40003577-CH10-SW16
    ///
    private static let standardSampleFormat: AVSampleFormat = AV_SAMPLE_FMT_FLTP
    
    init?(channelLayout: Int64, sampleRate: Int64, inputSampleFormat: AVSampleFormat) {
        
        super.init()
        
        // Set the input / output channel layouts as options prior to resampling.
        // NOTE - Our output channel layout will be the same as that of the input, since we don't
        // need to do any upmixing / downmixing here.
        
        self.inputChannelLayout = channelLayout
        self.outputChannelLayout = channelLayout
        
        // Set the input / output sample rates as options prior to resampling.
        // NOTE - Our output sample rate will be the same as that of the input, since we don't
        // need to do any upsampling / downsampling here.
        
        self.inputSampleRate = sampleRate
        self.outputSampleRate = sampleRate
        
        // Set the input / output sample formats as options prior to resampling.
        // NOTE - Our input sample format will be the format of the audio file being played,
        // and our output sample format will always be 32-bit floating point non-interleaved (aka planar).
        
        self.inputSampleFormat = inputSampleFormat
        self.outputSampleFormat = Self.standardSampleFormat
        
        initialize()
    }
    
    @inline(__always)
    func convertFrame(_ frame: FFmpegFrame,
                      andStoreIn outputDataPointers: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>) {
        
        let sampleCount = frame.sampleCount
        
        // Access the input data as pointers from the frame being resampled.
        frame.dataPointers.withMemoryRebound(to: UnsafePointer<UInt8>?.self, capacity: frame.intChannelCount) {inputDataPointers in
            
            convert(inputDataPointer: inputDataPointers, inputSampleCount: sampleCount,
                    outputDataPointer: outputDataPointers, outputSampleCount: sampleCount)
        }
    }
}
