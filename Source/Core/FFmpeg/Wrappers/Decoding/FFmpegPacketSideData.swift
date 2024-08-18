//
//  FFmpegPacketSideData.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class FFmpegPacketSideData {
    
    let pointer: UnsafePointer<AVPacketSideData>
    let size: Int32
    
    var avSideData: AVPacketSideData {pointer.pointee}
    
    lazy var replayGain: ReplayGain? = {
        
        guard let replayGainDataPtr = av_packet_side_data_get(self.pointer, self.size, AV_PKT_DATA_REPLAYGAIN) else {
            return nil
        }
        
        var replayGain: ReplayGain?
       
        replayGainDataPtr.pointee.data.withMemoryRebound(to: AVReplayGain.self, capacity: 1) {replayGainPointer in
            
            let avReplayGain = replayGainPointer.pointee
            
            replayGain = ReplayGain(trackGain: Float(avReplayGain.track_gain) / 100000,
                                    trackPeak: Float(avReplayGain.track_peak) / 100000,
                                    albumGain: Float(avReplayGain.album_gain) / 100000,
                                    albumPeak: Float(avReplayGain.album_peak) / 100000)
        }
        
        return replayGain
    }()
    
    init(pointer: UnsafePointer<AVPacketSideData>, size: Int32) {
        
        self.pointer = pointer
        self.size = size
    }
}
