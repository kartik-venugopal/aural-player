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
    let albumGainToPreventClipping: Float?
    
    private static let maxPeak: Float = 1
    
    init?(trackGain: Float? = nil, trackPeak: Float? = nil, albumGain: Float? = nil, albumPeak: Float? = nil) {
        
        guard trackGain != nil || albumGain != nil else {return nil}
        
        func gainToPreventClipping(gain: Float, peak: Float) -> Float {
            
            let newPeak = pow(10.0, gain / 20) * peak
            return newPeak > Self.maxPeak ? gain - (20 * log10(newPeak / Self.maxPeak)) : gain
        }
        
        self.trackGain = trackGain
        self.trackPeak = trackPeak
        
        if let theTrackGain = trackGain, let theTrackPeak = trackPeak {
            self.trackGainToPreventClipping = gainToPreventClipping(gain: theTrackGain, peak: theTrackPeak)
            
        } else {
            self.trackGainToPreventClipping = nil
        }
        
        self.albumGain = albumGain
        self.albumPeak = albumPeak
        
        if let theAlbumGain = albumGain, let theAlbumPeak = albumPeak {
            self.albumGainToPreventClipping = gainToPreventClipping(gain: theAlbumGain, peak: theAlbumPeak)
        } else {
            self.albumGainToPreventClipping = nil
        }
    }
    
    init(ebur128AnalysisResult: EBUR128AnalysisResult) {
        
        self.trackGain = Float(ebur128AnalysisResult.replayGain)
        self.trackPeak = Float(ebur128AnalysisResult.peak)
        self.trackGainToPreventClipping = Float(ebur128AnalysisResult.replayGainToPreventClipping)
        
        self.albumGain = nil
        self.albumPeak = nil
        self.albumGainToPreventClipping = nil
    }
}
