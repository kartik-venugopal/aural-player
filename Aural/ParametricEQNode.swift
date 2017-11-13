/*
    A special case (customized) extension of AVAudioUnitEQ to represent a 10 band parametric equalizer
*/

import Cocoa
import AVFoundation

class ParametricEQNode: AVAudioUnitEQ {
    
    var bassBandIndexes: [Int] = [0, 1, 2]
    var midBandIndexes: [Int] = [3, 4, 5, 6]
    var trebleBandIndexes: [Int] = [7, 8, 9]
    
    let bandsIndexRange: Range<Int>
    
    private let numberOfBands: Int = 10
    private let maxGain: Float = 20
    private let minGain: Float = -20
  
    override init() {
        
        bandsIndexRange = 0..<(numberOfBands)
        
        super.init(numberOfBands: numberOfBands)
        
        for i in 0..<numberOfBands {
            
            let band = bands[i]
            
            band.frequency = pow(2.0, Float(i + 5))
            
            // Constant
            band.bypass = false
            band.filterType = AVAudioUnitEQFilterType.parametric
            band.bandwidth = 0.5
        }
    }
    
    func increaseBass() -> [Int: Float] {
        return increaseBandGains(bassBandIndexes)
    }
    
    func decreaseBass() -> [Int: Float] {
        return decreaseBandGains(bassBandIndexes)
    }
    
    func increaseMids() -> [Int: Float] {
        return increaseBandGains(midBandIndexes)
    }
    
    func decreaseMids() -> [Int: Float] {
        return decreaseBandGains(midBandIndexes)
    }
    
    func increaseTreble() -> [Int: Float] {
        return increaseBandGains(trebleBandIndexes)
    }
    
    func decreaseTreble() -> [Int: Float] {
        return decreaseBandGains(trebleBandIndexes)
    }
    
    private func increaseBandGains(_ bandIndexes: [Int]) -> [Int: Float] {
        
        var newGainValues = [Int: Float]()
        bandIndexes.forEach({
            
            let band = bands[$0]
            band.gain = min(band.gain + 1, maxGain)
            newGainValues[$0] = band.gain
        })
        
        return newGainValues
    }
    
    private func decreaseBandGains(_ bandIndexes: [Int]) -> [Int: Float] {
        
        var newGainValues = [Int: Float]()
        bandIndexes.forEach({
            
            let band = bands[$0]
            band.gain = max(band.gain - 1, minGain)
            newGainValues[$0] = band.gain
        })
        
        return newGainValues
    }
    
    // Helper function to set gain for a band
    func setBand(_ index: Int, gain: Float) {
        if (bandsIndexRange.contains(index)) {
            bands[index].gain = gain
        }
    }
    
    // Helper function to set gain for all bands
    func setBands(_ allBands: [Int: Float]) {
        
        for (index, gain) in allBands {
            if (bandsIndexRange.contains(index)) {
                bands[index].gain = gain
            }
        }
    }
    
    func allBands() -> [Int: Float] {
        
        var allBands: [Int: Float] = [:]
        for index in 0..<bands.count {
            allBands[index] = bands[index].gain
        }
        
        return allBands
    }
}
