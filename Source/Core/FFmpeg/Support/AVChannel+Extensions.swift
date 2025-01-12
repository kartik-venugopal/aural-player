//
//  AVChannel+Extensions.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AVFoundation

extension AVChannel: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.rawValue)
    }
}

extension AVChannel {
    
    var avfChannel: AudioChannelBitmap? {
        Self.channelMapping[self]
    }
    
    private static let channelMapping: [AVChannel: AudioChannelBitmap] = [
        
        AV_CHAN_FRONT_LEFT:             .bit_Left,
        AV_CHAN_FRONT_RIGHT:            .bit_Right,
        AV_CHAN_FRONT_CENTER:           .bit_Center,
        AV_CHAN_LOW_FREQUENCY:          .bit_LFEScreen,
        AV_CHAN_BACK_LEFT:              .bit_LeftSurround,
        AV_CHAN_BACK_RIGHT:             .bit_RightSurround,
        AV_CHAN_FRONT_LEFT_OF_CENTER:   .bit_LeftCenter,
        AV_CHAN_FRONT_RIGHT_OF_CENTER:  .bit_RightCenter,
        AV_CHAN_BACK_CENTER:            .bit_CenterSurround,
        AV_CHAN_SIDE_LEFT:              .bit_LeftSurround,
        AV_CHAN_SIDE_RIGHT:             .bit_RightSurround,
        AV_CHAN_TOP_CENTER:             .bit_CenterTopFront,
        AV_CHAN_TOP_FRONT_LEFT:         .bit_LeftTopFront,
        AV_CHAN_TOP_FRONT_CENTER:       .bit_CenterTopFront,
        AV_CHAN_TOP_FRONT_RIGHT:        .bit_RightTopFront,
        AV_CHAN_TOP_BACK_LEFT:          .bit_TopBackLeft,
        AV_CHAN_TOP_BACK_CENTER:        .bit_TopBackCenter,
        AV_CHAN_TOP_BACK_RIGHT:         .bit_TopBackRight,
        AV_CHAN_STEREO_LEFT:            .bit_Left,
        AV_CHAN_STEREO_RIGHT:           .bit_Right,
        AV_CHAN_WIDE_LEFT:              .bit_Left,
        AV_CHAN_WIDE_RIGHT:             .bit_Right,
        AV_CHAN_SURROUND_DIRECT_LEFT:   .bit_LeftSurroundDirect,
        AV_CHAN_SURROUND_DIRECT_RIGHT:  .bit_RightSurroundDirect,
        AV_CHAN_LOW_FREQUENCY_2:        .bit_LFEScreen,
        AV_CHAN_TOP_SIDE_LEFT:          .bit_LeftTopMiddle,
        AV_CHAN_TOP_SIDE_RIGHT:         .bit_RightTopMiddle,
        AV_CHAN_BOTTOM_FRONT_CENTER:    .bit_Center,
        AV_CHAN_BOTTOM_FRONT_LEFT:      .bit_Left,
        AV_CHAN_BOTTOM_FRONT_RIGHT:     .bit_Right
    ]
}
