/*
    A special case (customized) extension of AVAudioUnitEQ to represent a 10 band parametric equalizer
*/

import Cocoa
import AVFoundation

class ParametricEQNode: AVAudioUnitEQ {
  
    override init() {
        
        super.init(numberOfBands: 10)
        
        for i in 0...9 {
            
            let band = bands[Int(i)]
            
            band.frequency = pow(2.0, Float(i + 5))
            
            // Constant
            band.bypass = false
            band.filterType = AVAudioUnitEQFilterType.parametric
            band.bandwidth = 0.5
        }
    }
    
    // Helper function to set gain for a band
    func setBand(_ freq: Float, gain: Float) {
        
        let index = Int(log2f(freq) - 5)
        bands[index].gain = gain
    }
    
    // Helper function to set gain for all bands
    func setBands(_ allBands: [Int: Float]) {
        
        for (freq, gain) in allBands {
            
            let index = Int(log2f(Float(freq))) - 5
            bands[index].gain = gain
        }
    }
}
