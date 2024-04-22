//
//  AVAudioFormatExtensions.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import AVFoundation

extension AVAudioFormat {
    
    var channelLayoutString: String {
        
        let channelCount: Int32 = Int32(self.channelCount)
        
        guard let layoutTag = formatDescription.audioFormatList.map({$0.mChannelLayoutTag}).first else {return AVAudioChannelLayout.defaultDescription(channelCount: channelCount)}
        
        let layout = AVAudioChannelLayout(layoutTag: layoutTag)
        return layout?.layout.pointee.description ?? AVAudioChannelLayout.defaultDescription(channelCount: channelCount)
    }
    
    #if os(macOS)

    ///
    /// A convenient way to instantiate an AVAudioFormat given an ffmpeg sample format, sample rate, and channel layout identifier.
    ///
    convenience init?(from ffmpegFormat: FFmpegAudioFormat) {
        
        guard let avfChannelLayout: AVAudioChannelLayout = FFmpegChannelLayoutsMapper.mapLayout(ffmpegLayout: ffmpegFormat.channelLayout.id) else {
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
    
    #endif
}
