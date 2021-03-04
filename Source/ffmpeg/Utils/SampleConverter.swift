import AVFoundation

///
/// A contract for a sample converter that performs conversion of PCM audio samples to the standard format suitable for playback in an AVAudioEngine,
/// i.e. 32-bit floating point non-interleaved (aka planar).
///
/// ```
/// Such a conversion is only required when codecs produce PCM samples that are not already in
/// the required standard format.
/// ```
///
protocol SampleConverterProtocol {
    
    ///
    /// Returns whether or not this sample converter can handle a conversion from the
    /// given input format to the required standard Core Audio format.
    ///
    /// - Parameter inputFormat: The audio format of the samples to be converted.
    ///
    /// - returns: true if the conversion from **inputFormat** is supported, false otherwise.
    ///
    func supports(inputFormat: FFmpegAudioFormat) -> Bool
    
    ///
    /// Converts samples from a given frame buffer into the standard Core Audio sample format,
    /// and copies the output samples into the given audio buffer.
    ///
    /// - Parameter frameBuffer:    A buffer containing frames whose samples need to be converted.
    ///
    /// - Parameter audioBuffer:    An audio buffer to which the output samples need to be copied once the format conversion is completed.
    ///
    func convert(samplesIn frameBuffer: FFmpegFrameBuffer, andCopyTo audioBuffer: AVAudioPCMBuffer)
}

///
/// A facade for all sample format conversions.
///
/// Delegates to different sample converter implementations to do the actual conversions.
///
class SampleConverter: SampleConverterProtocol {

    /// AVFoundation-based sample converter (this is the preferred implementation).
    private let avfConverter: AVFSampleConverter = AVFSampleConverter()
    
    /// FFmpeg-based sample converter (i.e. libswresample).
    private let ffmpegConverter: FFmpegSampleConverter = FFmpegSampleConverter()
    
    /// This function is not really used, but implemented to conform to **SampleConverterProtocol**.
    func supports(inputFormat: FFmpegAudioFormat) -> Bool {
        return true
    }
    
    func convert(samplesIn frameBuffer: FFmpegFrameBuffer, andCopyTo audioBuffer: AVAudioPCMBuffer) {
        
        // If the AVFoundation converter supports this conversion, use it.
        if avfConverter.supports(inputFormat: frameBuffer.audioFormat) {
            
            avfConverter.convert(samplesIn: frameBuffer, andCopyTo: audioBuffer)
            
        } else {
            
            // ... otherwise, fall back to the FFmpeg sample converter.
            ffmpegConverter.convert(samplesIn: frameBuffer, andCopyTo: audioBuffer)
        }
    }
}
