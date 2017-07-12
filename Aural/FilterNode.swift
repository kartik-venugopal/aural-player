/*
    A special case (customized) extension of AVAudioUnitEQ to represent a filter node with a high pass and low pass band
*/

import Cocoa
import AVFoundation

class FilterNode: AVAudioUnitEQ {
    
    var lowPassBand: AVAudioUnitEQFilterParameters {
        return bands[0]
    }
    
    var highPassBand: AVAudioUnitEQFilterParameters {
        return bands[1]
    }
    
    override init() {
        
        super.init(numberOfBands: 2)
        
        lowPassBand.bypass = false
        lowPassBand.filterType = AVAudioUnitEQFilterType.ResonantLowPass
        lowPassBand.bandwidth = 0.5
        
        highPassBand.bypass = false
        highPassBand.filterType = AVAudioUnitEQFilterType.ResonantHighPass
        highPassBand.bandwidth = 0.5
    }
}
