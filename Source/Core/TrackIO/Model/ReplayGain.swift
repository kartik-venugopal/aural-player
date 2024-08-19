//
//  ReplayGain.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

struct ReplayGain {
    
    let trackGain: Float?
    let trackPeak: Float?
    let trackGainToPreventClipping: Float?
    
    let albumGain: Float?
    let albumPeak: Float?
    
    private static let maxPeak: Float = 1
    
    init?(trackGain: Float? = nil, trackPeak: Float? = nil, albumGain: Float? = nil, albumPeak: Float? = nil) {
        
        guard trackGain != nil || albumGain != nil else {return nil}
        
        self.trackGain = trackGain
        self.trackPeak = trackPeak
        
        var trackGainToPreventClipping: Float
        
        if let theTrackGain = trackGain, let theTrackPeak = trackPeak {
            
            trackGainToPreventClipping = theTrackGain
            
            let newPeak = pow(10.0, theTrackGain / 20) * theTrackPeak
            
            if newPeak > Self.maxPeak {
                trackGainToPreventClipping -= (20 * log10(newPeak / Self.maxPeak))
            }
            
            self.trackGainToPreventClipping = trackGainToPreventClipping
            
        } else {
            self.trackGainToPreventClipping = nil
        }
        
        self.albumGain = albumGain
        self.albumPeak = albumPeak
    }
    
    init(ebur128AnalysisResult: EBUR128AnalysisResult) {
        
        self.trackGain = Float(ebur128AnalysisResult.replayGain)
        self.trackPeak = Float(ebur128AnalysisResult.peak)
        self.trackGainToPreventClipping = Float(ebur128AnalysisResult.replayGainToPreventClipping)
        
        self.albumGain = nil
        self.albumPeak = nil
    }
}
