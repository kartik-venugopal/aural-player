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

extension AVAudioChannelLayout {
    
    static func defaultDescription(channelCount: Int32) -> String {
        
        switch channelCount {
            
        case 1: return "Mono"
            
        case 2: return "Stereo (L R)"
            
        case 3: return "2.1"
            
        case 6: return "5.1"
            
        case 8: return "7.1"
            
        case 10: return "9.1"
            
        default: return "\(channelCount) channels"
            
        }
    }
}

extension AudioChannelLayout {
    
    static let sizeOfLayout: UInt32 = UInt32(MemoryLayout<AudioChannelLayout>.size)
    
    var description: String? {
        
        var layout: AudioChannelLayout = self
        
        var nameSize : UInt32 = 0
        var status = AudioFormatGetPropertyInfo(kAudioFormatProperty_ChannelLayoutName,
                                                Self.sizeOfLayout, &layout, &nameSize)
        
        if status != noErr {return nil}
        
        var formatName: CFString = String() as CFString
        status = AudioFormatGetProperty(kAudioFormatProperty_ChannelLayoutName,
                                        Self.sizeOfLayout, &layout, &nameSize, &formatName)
        
        if status != noErr {return nil}
        
        return String(formatName as NSString)
    }
}

extension AVAudioFormat {
    
    var channelLayoutString: String {
        
        let channelCount: Int32 = Int32(self.channelCount)
        
        if #available(OSX 10.15, *) {
            
            guard let layoutTag = formatDescription.audioFormatList.map({$0.mChannelLayoutTag}).first else {return AVAudioChannelLayout.defaultDescription(channelCount: channelCount)}
            
            let layout = AVAudioChannelLayout(layoutTag: layoutTag)
            return layout?.layout.pointee.description ?? AVAudioChannelLayout.defaultDescription(channelCount: channelCount)
            
        } else {
            
            var aclSizeInt: Int = 0
            let aclPtr: UnsafePointer<AudioChannelLayout>? =
                CMAudioFormatDescriptionGetChannelLayout(formatDescription, sizeOut: &aclSizeInt)
            
            return aclPtr?.pointee.description ?? AVAudioChannelLayout.defaultDescription(channelCount: channelCount)
        }
    }

}
