//
//  ReplayGain.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

struct ReplayGain {
    
    let trackGain: Float?
    let trackPeak: Float?
    let albumGain: Float?
    let albumPeak: Float?
    
    init?(trackGain: Float? = nil, trackPeak: Float? = nil, albumGain: Float? = nil, albumPeak: Float? = nil) {
        
        guard trackGain != nil || albumGain != nil else {return nil}
        
        self.trackGain = trackGain
        self.trackPeak = trackPeak
        self.albumGain = albumGain
        self.albumPeak = albumPeak
    }
}
