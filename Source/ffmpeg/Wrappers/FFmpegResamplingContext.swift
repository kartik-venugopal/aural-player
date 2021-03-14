import Foundation

///
/// A wrapper around an ffmpeg SwrContext that performs a resampling conversion:
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
    private var resampleCtx: OpaquePointer?
    
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
