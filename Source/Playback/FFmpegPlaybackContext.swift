import AVFoundation

class FFmpegPlaybackContext: PlaybackContextProtocol {
    
    let file: URL
    
    var fileContext: FFmpegFileContext!
    var decoder: FFmpegDecoder!
    
    var audioCodec: FFmpegAudioCodec {
        decoder.codec
    }
    
    let audioFormat: AVAudioFormat
    
    ///
    /// The maximum number of samples that will be read, decoded, and scheduled for **immediate** playback,
    /// i.e. when **play(file)** is called, triggered by the user.
    ///
    /// # Notes #
    ///
    /// 1. This value should be small enough so that, when starting playback
    /// of a file, there is little to no perceived lag. Typically, this should represent about 2-5 seconds of audio (depending on sample rate).
    ///
    /// 2. This value should generally be smaller than *sampleCountForDeferredPlayback*.
    ///
    var sampleCountForImmediatePlayback: Int32 = 0
    
    ///
    /// The maximum number of samples that will be read, decoded, and scheduled for **deferred** playback, i.e. playback that will occur
    /// at a later time, as the result, of a recursive scheduling task automatically triggered when a previously scheduled audio buffer has finished playing.
    ///
    /// # Notes #
    ///
    /// 1. The greater this value, the longer each recursive scheduling task will take to complete, and the larger the memory footprint of each audio buffer.
    /// The smaller this value, the more often disk reads will occur. Choose a value that is a good balance between memory usage, decoding / resampling time, and frequency of disk reads.
    /// Example: 10-20 seconds of audio (depending on sample rate).
    ///
    /// 2. This value should generally be larger than *sampleCountForImmediatePlayback*.
    ///
    var sampleCountForDeferredPlayback: Int32 = 0
    
    var sampleRate: Double = 0
    
    var frameCount: Int64 = 0
    
    var duration: Double {fileContext.duration}
    
    init(for file: URL) throws {
        
        self.file = file
        self.fileContext = try FFmpegFileContext(for: file)
        self.decoder = try FFmpegDecoder(for: fileContext)
        
        let codec = decoder.codec
        
        let sampleRate: Int32 = codec.sampleRate
        self.sampleRate = Double(sampleRate)
        
        if let audioStream = fileContext.bestAudioStream {
            self.frameCount = Int64(Double(audioStream.sampleRate) * fileContext.duration)
        }
        
        let channelLayout: AVAudioChannelLayout = FFmpegChannelLayoutsMapper.mapLayout(ffmpegLayout: Int(codec.channelLayout)) ?? .stereo
        self.audioFormat = AVAudioFormat(standardFormatWithSampleRate: Double(sampleRate), channelLayout: channelLayout)

        // The effective sample rate, which also takes into account the channel count, gives us a better idea
        // of the computational cost of decoding and resampling the given file, as opposed to just the
        // sample rate.
        let channelCount: Int32 = codec.channelCount
        let effectiveSampleRate: Int32 = sampleRate * channelCount

        switch effectiveSampleRate {

        case 0..<100000:

            // 44.1 / 48 KHz stereo

            sampleCountForImmediatePlayback = 5 * sampleRate    // 5 seconds of audio
            sampleCountForDeferredPlayback = 10 * sampleRate    // 10 seconds of audio

        case 100000..<500000:

            // 96 / 192 KHz stereo

            sampleCountForImmediatePlayback = 3 * sampleRate    // 3 seconds of audio
            sampleCountForDeferredPlayback = 10 * sampleRate    // 10 seconds of audio

        default:

            // 96 KHz surround and higher sample rates

            sampleCountForImmediatePlayback = 2 * sampleRate    // 2 seconds of audio
            sampleCountForDeferredPlayback = 7 * sampleRate     // 7 seconds of audio
        }
    }
    
    func open() throws {
        
        if fileContext == nil {
            
            fileContext = try FFmpegFileContext(for: file)
            decoder = try FFmpegDecoder(for: fileContext)
        }
    }
    
    func close() {

        decoder = nil
        fileContext = nil
    }
}

extension AVAudioChannelLayout {
    
    static let stereo: AVAudioChannelLayout = AVAudioChannelLayout(layoutTag: kAudioChannelLayoutTag_Stereo)!
}
