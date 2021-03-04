import AVFoundation

extension AVAudioFormat {

    ///
    /// A convenient way to instantiate an AVAudioFormat given an ffmpeg sample format, sample rate, and channel layout identifier.
    ///
    convenience init?(from ffmpegFormat: FFmpegAudioFormat) {
        
        guard let avfChannelLayout: AVAudioChannelLayout = FFmpegChannelLayoutsMapper.mapLayout(ffmpegLayout: Int(ffmpegFormat.channelLayout)) else {
            return nil
        }
        
        var commonFmt: AVAudioCommonFormat
        
        switch ffmpegFormat.avSampleFormat {
            
        case AV_SAMPLE_FMT_S16, AV_SAMPLE_FMT_S16P:
            
            commonFmt = .pcmFormatInt16
            
        case AV_SAMPLE_FMT_S32, AV_SAMPLE_FMT_S32P:
            
            commonFmt = .pcmFormatInt32
            
        case AV_SAMPLE_FMT_FLT, AV_SAMPLE_FMT_FLTP:
            
            commonFmt = .pcmFormatFloat32
            
        default:
            
            return nil
        }
        
        self.init(commonFormat: commonFmt, sampleRate: Double(ffmpegFormat.sampleRate),
                  interleaved: ffmpegFormat.isInterleaved, channelLayout: avfChannelLayout)
    }
}
