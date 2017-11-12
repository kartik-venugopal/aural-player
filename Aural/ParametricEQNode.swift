/*
    A special case (customized) extension of AVAudioUnitEQ to represent a 10 band parametric equalizer
*/

import Cocoa
import AVFoundation

class ParametricEQNode: AVAudioUnitEQ {
    
    var bassBands: [AVAudioUnitEQFilterParameters] {
        return [bands[0], bands[1], bands[2]]
    }
    
    var midBands: [AVAudioUnitEQFilterParameters] {
        return [bands[3], bands[4], bands[5], bands[6]]
    }
    
    var trebleBands: [AVAudioUnitEQFilterParameters] {
        return [bands[7], bands[8], bands[9]]
    }
    
    var bandsIndexRange: Range<Int> {
        return 0..<(numberOfBands)
    }
    
    private let numberOfBands: Int = 10
  
    override init() {
        
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
        
        var newGainValues = [Int: Float]()
        var index = 0
        bassBands.forEach({
            
            let newGainValue = min($0.gain + 1, 20)
            $0.gain = newGainValue
            newGainValues[index] = newGainValue
            index += 1
        })
        
        return newGainValues
    }
    
    func decreaseBass() -> [Int: Float] {
        
        var newGainValues = [Int: Float]()
        var index = 0
        bassBands.forEach({
            
            let newGainValue = max($0.gain - 1, -20)
            $0.gain = newGainValue
            newGainValues[index] = newGainValue
            index += 1
        })
        
        return newGainValues
    }
    
    func increaseMids() -> [Float] {
        
        var newGainValues = [Float]()
        midBands.forEach({
            
            let newGainValue = min($0.gain + 1, 20)
            $0.gain = newGainValue
            newGainValues.append(newGainValue)
        })
        
        return newGainValues
    }
    
    func increaseTreble() -> [Float] {
        
        var newGainValues = [Float]()
        trebleBands.forEach({
            
            let newGainValue = min($0.gain + 1, 20)
            $0.gain = newGainValue
            newGainValues.append(newGainValue)
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
