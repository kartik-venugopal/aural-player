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

struct ReplayGain: Codable {
    
    let trackGain: Float?
    let trackPeak: Float?
    
    var trackGainToPreventClipping: Float? = nil
    
    let albumGain: Float?
    let albumPeak: Float?
    
    var albumGainToPreventClipping: Float? = nil
    
    init?(trackGain: Float? = nil, trackPeak: Float? = nil, albumGain: Float? = nil, albumPeak: Float? = nil) {
        
        guard trackGain != nil || albumGain != nil else {return nil}
        
        self.trackGain = trackGain
        self.trackPeak = trackPeak
        
        self.albumGain = albumGain
        self.albumPeak = albumPeak
    }
    
    private func gainToPreventClipping(gain: Float, peak: Float, usingMaxPeakLevel maxPeakLevel: Float) -> Float {
        
        let maxPeak = pow(10.0, maxPeakLevel / 20.0)
        let newPeak = pow(10.0, gain / 20) * peak
        return newPeak > maxPeak ? gain - (20 * log10(newPeak / maxPeak)) : gain
    }
    
    mutating func applyClippingPrevention(usingMaxPeakLevel maxPeakLevel: Float) {
        
        applyClippingPreventionToTrackGain(usingMaxPeakLevel: maxPeakLevel)
        applyClippingPreventionToAlbumGain(usingMaxPeakLevel: maxPeakLevel)
    }
    
    mutating func applyClippingPreventionToTrackGain(usingMaxPeakLevel maxPeakLevel: Float) {
        
        if let theTrackGain = trackGain, let theTrackPeak = trackPeak {
            self.trackGainToPreventClipping = gainToPreventClipping(gain: theTrackGain, peak: theTrackPeak, usingMaxPeakLevel: maxPeakLevel)
            
        } else {
            self.trackGainToPreventClipping = nil
        }
    }
    
    mutating func applyClippingPreventionToAlbumGain(usingMaxPeakLevel maxPeakLevel: Float) {
        
        if let theAlbumGain = albumGain, let theAlbumPeak = albumPeak {
            self.albumGainToPreventClipping = gainToPreventClipping(gain: theAlbumGain, peak: theAlbumPeak, usingMaxPeakLevel: maxPeakLevel)
        } else {
            self.albumGainToPreventClipping = nil
        }
    }
    
    init(ebur128AnalysisResult: EBUR128AnalysisResult) {
        
        self.trackGain = Float(ebur128AnalysisResult.replayGain)
        self.trackPeak = Float(ebur128AnalysisResult.peak)
        
        self.albumGain = nil
        self.albumPeak = nil
    }
}
