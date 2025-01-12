//
//  FFmpegChannelLayout.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AVFoundation

class FFmpegChannelLayout {
    
    let avChannelLayout: AVChannelLayout
    let numberOfChannels: Int32
    private(set) lazy var avfLayout: AVAudioChannelLayout = avChannelLayout.computedAVFLayout
    
    lazy var description: String = {
       
        let layoutString = FFmpegString(size: 100)
        
        withUnsafePointer(to: avChannelLayout) {ptr -> Void in
            av_channel_layout_describe(ptr, layoutString.pointer, layoutString.size)
        }
        
        return layoutString.string.replacingOccurrences(of: "(", with: " (").capitalized
    }()

    
    init(encapsulating avChannelLayout: AVChannelLayout) {
        
        self.avChannelLayout = avChannelLayout
        self.numberOfChannels = avChannelLayout.nb_channels
    }
}
