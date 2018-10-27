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
            band.bandwidth = 1
        }
    }
    
    func increaseBass(_ increment: Float) -> [Int: Float] {
        
        let _ = increaseBandGains(bassBandIndexes, increment)
        return allBands()
    }
    
    func decreaseBass(_ decrement: Float) -> [Int: Float] {
        let _ = decreaseBandGains(bassBandIndexes, decrement)
        return allBands()
    }
    
    func increaseMids(_ increment: Float) -> [Int: Float] {
        let _ = increaseBandGains(midBandIndexes, increment)
        return allBands()
    }
    
    func decreaseMids(_ decrement: Float) -> [Int: Float] {
        let _ = decreaseBandGains(midBandIndexes, decrement)
        return allBands()
    }
    
    func increaseTreble(_ increment: Float) -> [Int: Float] {
        let _ = increaseBandGains(trebleBandIndexes, increment)
        return allBands()
    }
    
    func decreaseTreble(_ decrement: Float) -> [Int: Float] {
        let _ = decreaseBandGains(trebleBandIndexes, decrement)
        return allBands()
    }
    
    private func increaseBandGains(_ bandIndexes: [Int], _ increment: Float) -> [Int: Float] {
        
        var newGainValues = [Int: Float]()
        bandIndexes.forEach({
            
            let band = bands[$0]
            band.gain = min(band.gain + increment, maxGain)
            newGainValues[$0] = band.gain
        })
        
        return newGainValues
    }
    
    private func decreaseBandGains(_ bandIndexes: [Int], _ decrement: Float) -> [Int: Float] {
        
        var newGainValues = [Int: Float]()
        bandIndexes.forEach({
            
            let band = bands[$0]
            band.gain = max(band.gain - decrement, minGain)
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
