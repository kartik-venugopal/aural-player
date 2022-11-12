//
//  FFmpegChannelLayout.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation
import AVFAudio

///
/// Wrapper around an ffmpeg channel layout identifier that provides convenience functions, eg.
/// readable description.
///
class FFmpegChannelLayout {
    
    let id: UInt64
    lazy var avfLayout: AVAudioChannelLayout = FFmpegChannelLayoutsMapper.mapLayout(ffmpegLayout: id) ?? .stereo
    let readableString: String
    
    init(id: UInt64, channelCount: Int32) {
        
        self.id = id != 0 ? id : UInt64(av_get_default_channel_layout(channelCount))
        self.readableString = FFmpegChannelLayoutsMapper.readableString(for: id, channelCount: channelCount)
    }
    
    static let zero: FFmpegChannelLayout = .init(id: 0, channelCount: 0)
}
