import Foundation

class EQMapping {
    
    let srcBands: [Float: Float]
    let srcBandwidth: Float
    let targetFreqs: [Float]
    let targetBandwidth: Float
    
    var mappedBands: [Float: Float] = [:]
    
    init(_ srcBands: [Float: Float], _ srcBandwidth: Float, _ targetFreqs: [Float], _ targetBandwidth: Float) {
        
        self.srcBands = srcBands
        self.srcBandwidth = srcBandwidth
        self.targetFreqs = targetFreqs
        self.targetBandwidth = targetBandwidth
        
        targetFreqs.forEach({mapTargetBand($0)})
    }
    
    private func mapTargetBand(_ freq: Float) {
        
        let neighboringBands = insertTargetBand(freq)
        
        if neighboringBands.hasMatchingBand {
            
            mappedBands[freq] = srcBands[freq]
            return
        }
        
        // Determine gain for neighboring bands
        let leftBand = neighboringBands.leftBand
        let rightBand = neighboringBands.rightBand

        if leftBand != nil && rightBand != nil {
            
            let gainL = centerGain(leftBand!, freq)
            let gainR = centerGain(rightBand!, freq)
            
            // Weighted average
            let distance = octavesBetweenFreqs(rightBand!, leftBand!)
            let dL = octavesBetweenFreqs(freq, leftBand!)
            
            let wtL = 1 - (dL / distance)
            let wtR = 1 - wtL
            
            let weightedGain = (wtL * gainL) + (wtR * gainR)
            mappedBands[freq] = weightedGain
            
        } else if leftBand != nil {
            
            mappedBands[freq] = centerGain(leftBand!, freq)
            
        } else {
            
            mappedBands[freq] = centerGain(rightBand!, freq)
        }
    }
    
    private func insertTargetBand(_ freq: Float) -> (hasMatchingBand: Bool, leftBand: Float?, rightBand: Float?) {
        
        if srcBands[freq] != nil {
            return (true, nil, nil)
        }
        
        var cur = 0
        var rightBand: Float?
        var leftBand: Float?
        
        let srcFreqs = srcBands.keys.sorted()
        
        while cur < srcFreqs.count {
            
            let bandF = srcFreqs[cur]
            
            if freq < bandF {
                
                rightBand = bandF
                if cur >= 1 {leftBand = srcFreqs[cur - 1]}
                break
            }
            
            cur.increment()
        }
        
        if cur == srcFreqs.count {
            leftBand = srcFreqs.last
        }
        
        return (false, leftBand, rightBand)
    }
    
    private func centerGain(_ srcFreq: Float, _ centerFreq: Float) -> Float {
        
        var srcGain: Float = srcBands[srcFreq]!
        
        if srcGain == 0 {return 0}
        
        let sign: Float = srcGain < 0 ? -1 : 1
        srcGain = fabsf(srcGain)
        
        let attenuation = attenuationBetween(centerFreq, srcFreq, targetBandwidth)
        var targetGain = (srcGain + attenuation) * sign
        
        // Check for upper and lower bounds
        if targetGain > AppConstants.Sound.eqGainMax {
            targetGain = AppConstants.Sound.eqGainMax
        } else if targetGain < AppConstants.Sound.eqGainMin {
            targetGain = AppConstants.Sound.eqGainMin
        }
        
        return targetGain
    }
}

fileprivate func attenuationBetween(_ centerFreq: Float, _ targetFreq: Float, _ bandwidth: Float) -> Float {
    return 6 * octavesBetweenFreqs(targetFreq, centerFreq) / bandwidth
}

fileprivate func octavesBetweenFreqs(_ f1: Float, _ f2: Float) -> Float {
    return fabsf(log2(f2 / f1))
}
