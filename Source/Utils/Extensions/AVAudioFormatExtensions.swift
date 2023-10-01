//
//  AVAudioFormatExtensions.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import AVFoundation

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
