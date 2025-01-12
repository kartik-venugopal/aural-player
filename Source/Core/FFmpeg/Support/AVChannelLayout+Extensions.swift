//
//  AVChannelLayout+Extensions.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AVFoundation

extension AVChannelLayout {
    
    var computedAVFLayout: AVAudioChannelLayout {
        
        switch order {
            
        case AV_CHANNEL_ORDER_NATIVE:
            return avfLayoutForNativeOrder
            
        case AV_CHANNEL_ORDER_UNSPEC:
            return defaultLayoutForChannelCount
            
        case AV_CHANNEL_ORDER_CUSTOM:
            return avfLayoutForCustomOrder
            
        default:
            return .stereo
        }
    }
    
    private var avfLayoutForNativeOrder: AVAudioChannelLayout {
        mapChannelsToAVFLayout(nativeOrderChannels)
    }
    
    private var nativeOrderChannels: [AVChannel] {
       
        var theChannels: [AVChannel] = []
        
        let binaryString = String(u.mask, radix: 2)
        
        for (index, char) in binaryString.reversed().enumerated() {
            
            if char == "1" {
                theChannels.append(AVChannel(rawValue: index <= AV_CHAN_TOP_BACK_RIGHT.rawValue ? Int32(index) : Int32(index + 11)))
            }
        }
        
        return theChannels
    }
    
    private var avfLayoutForCustomOrder: AVAudioChannelLayout {
        mapChannelsToAVFLayout(customOrderChannels)
    }
    
    private var customOrderChannels: [AVChannel] {
       
        guard let customChannelsPtr = self.u.map else {return []}
        return (0..<Int(nb_channels)).map {customChannelsPtr[$0].id}
    }
    
    private func mapChannelsToAVFLayout(_ channels: [AVChannel]) -> AVAudioChannelLayout {
        
        var avfChannels: AudioChannelBitmap = .init()
        for avfChannel in channels.compactMap({$0.avfChannel}) {
            avfChannels.insert(avfChannel)
        }
        
        var layout = AudioChannelLayout.init()
        layout.mChannelBitmap = avfChannels
        layout.mChannelLayoutTag = kAudioChannelLayoutTag_UseChannelBitmap
        
        return AVAudioChannelLayout.init(layout: &layout)
    }
    
    private var defaultLayoutForChannelCount: AVAudioChannelLayout {
        .defaultLayoutForChannelCount(AVAudioChannelCount(self.nb_channels))
    }
}
