//
//  EQPlot.swift
//  Aural
//
//  Created by Wald Schlafer on 10/30/18.
//  Copyright © 2018 Anonymous. All rights reserved.
//

import Foundation

class EQPlot {
    
    let frequencies: [Float]
    let bandwidth: Float
    let gains: [Int: Float]
    
    init(_ frequencies: [Float], _ gains: [Int: Float], _ bandwidth: Float) {
        
        self.frequencies = frequencies
        self.gains = gains
        self.bandwidth = bandwidth
    }
    
    func mapBands(_ targetFrequencies: [Float]) -> [Int: Float] {
        
        var bands: [Int: Float] = [:]
        var index = 0
        
        for freq in targetFrequencies {
            
            bands[index] = estimateGainAtFrequency(freq)
            index += 1
        }
        
        return bands
    }
    
    private func estimateGainAtFrequency(_ frequency: Float) -> Float {
        
        print("\nFor F=", frequency)
        
        // 1 - Figure out which two bands this F lies between
        // 2 - Figure out octaves between L band and F: o1
        // 3 - Figure out attenuation from L band: G1
        // 4 - Figure out octaves between R band and F: o2
        // 5 - Figure out attenuation from R band: G2
        // 6 - Average G1 and G2
        
        var cur: Int = 0
        
        var leftBand: Int = -1
        var rightBand: Int = -1
        
        while cur < frequencies.count {
            
            let bandF = frequencies[cur]
            
            if frequency < bandF {
                
                rightBand = cur
                if cur >= 1 {leftBand = cur - 1}
                break
                
            } else if frequency == bandF {
                return gains[cur]!
            }
            
            cur += 1
        }
        
        // Reached end of freqs array
        if cur == frequencies.count {leftBand = frequencies.count - 1}
        
        if leftBand >= 0 && rightBand >= 0 {
            
            // Between 2 bands
            let leftFreq = frequencies[leftBand]
            let rightFreq = frequencies[rightBand]
            
            let gainL = weightedRelativeGain(frequency, leftFreq)
            let gainR = weightedRelativeGain(frequency, rightFreq)
            
            print("GainAvg=", gainL, gainR, (gainL + gainR))
            return (gainL + gainR)
            
        } else if leftBand >= 0 {
            
            let leftFreq = frequencies[leftBand]
            let gainL = relativeGain(frequency, leftFreq)
            
            print("GainL=", gainL)
            return gainL
            
        } else {
            
            let rightFreq = frequencies[rightBand]
            let gainR = relativeGain(frequency, rightFreq)
            
            print("GainR=", gainR)
            return gainR
        }
    }
    
    private func relativeGain(_ targetFreq: Float, _ centerFreq: Float) -> Float {
        
        let centerFreqIndex = frequencies.firstIndex(of: centerFreq)!
        let centerGain = gains[centerFreqIndex]!
        
        let attenuation = attenuationBetween(centerFreq, targetFreq)
        
        var targetGain = centerGain - attenuation
        if !hasSameSign(targetGain, centerGain) {targetGain = 0}
        
        print("CGain", centerGain, "Rel:", targetGain)
        return targetGain
    }
    
    private func weightedRelativeGain(_ targetFreq: Float, _ centerFreq: Float) -> Float {
        
        let relGain = relativeGain(targetFreq, centerFreq)
        let oct = octavesBetweenFreqs(targetFreq, centerFreq)
        let weight = self.bandwidth - oct
        
        print("Oct", oct, "Weight", weight, "RelGain", relGain)
        
        return relGain * weight
    }
    
    private func attenuationBetween(_ centerFreq: Float, _ targetFreq: Float) -> Float {
        return 6 * octavesBetweenFreqs(targetFreq, centerFreq)
    }
}

fileprivate func hasSameSign(_ f1: Float, _ f2: Float) -> Bool {
    return (f1 == f2) || (f1 > 0 && f2 > 0) || (f1 < 0 && f2 < 0)
}

fileprivate func octavesBetweenFreqs(_ f1: Float, _ f2: Float) -> Float {
    return f2 > f1 ? log2(f2 / f1) : log2(f1 / f2)
}
