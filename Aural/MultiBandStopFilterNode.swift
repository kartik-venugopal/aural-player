/*
    A special (customized) extension of AVAudioUnitEQ to represent a 3-band band-stop filter, with bands for bass, mid, and treble frequency ranges
*/

import Cocoa
import AVFoundation

class MultiBandStopFilterNode: AVAudioUnitEQ {
    
    // Frequency ranges for each of the 3 bands
    
    static let bass_min: Float = 20
    static let bass_max: Float = 250
    
    static let mid_min: Float = 251
    static let mid_max: Float = 2000
    
    static let treble_min: Float = 2001
    static let treble_max: Float = 20000
    
    var bassBand: AVAudioUnitEQFilterParameters {
        return bands[0]
    }
    
    var midBand: AVAudioUnitEQFilterParameters {
        return bands[1]
    }
    
    var trebleBand: AVAudioUnitEQFilterParameters {
        return bands[2]
    }
    
    override init() {
        
        super.init(numberOfBands: 3)
        
        bassBand.bypass = true
        bassBand.filterType = AVAudioUnitEQFilterType.parametric
        bassBand.bandwidth = 0.05
        bassBand.gain = -24
        
        midBand.bypass = true
        midBand.filterType = AVAudioUnitEQFilterType.parametric
        midBand.bandwidth = 0.05
        midBand.gain = -24

        trebleBand.bypass = true
        trebleBand.filterType = AVAudioUnitEQFilterType.parametric
        trebleBand.bandwidth = 0.05
        trebleBand.gain = -24
    }
    
    private func setBand(_ band: AVAudioUnitEQFilterParameters, _ min: Float, _ max: Float) {
        
        // Should never happen, but for safety
        if (min > max) {
            return
        }
        
        // Frequency at the center of the band is the geometric mean of the min and max frequencies
        let centerFrequency = sqrt(min * max)
        
        // Bandwidth in octaves is the log of the ratio of max to min
        // Ex: If min=200 and max=800, bandwidth = 2 octaves (200 to 400, and 400 to 800)
        let bandwidth = log2(max / min)
        
        // If calculated bandwidth < 0.05, set bypass to true (bandwidth is negligible)
        let bypassBand: Bool = bandwidth < 0.05
        
        band.frequency = centerFrequency
        band.bandwidth = bandwidth
        band.bypass = bypassBand
    }

    func setFilterBassBand(_ min: Float, _ max: Float) {
        setBand(bassBand, min, max)
    }

    func setFilterMidBand(_ min: Float, _ max: Float) {
        setBand(midBand, min, max)
    }
    
    func setFilterTrebleBand(_ min: Float, _ max: Float) {
        setBand(trebleBand, min, max)
    }
    
    // Calculates and returns all band frequency ranges
    func getBands() -> (bass: (min: Float, max: Float), mid: (min: Float, max: Float), treble: (min: Float, max: Float)) {
        
        let bass = calcMinMaxForCenterFrequency(freqC: bassBand.frequency, bandwidth: bassBand.bandwidth)
        let mid = calcMinMaxForCenterFrequency(freqC: midBand.frequency, bandwidth: midBand.bandwidth)
        let treble = calcMinMaxForCenterFrequency(freqC: trebleBand.frequency, bandwidth: trebleBand.bandwidth)
        
        return (bass, mid, treble)
    }
    
    private func calcMinMaxForCenterFrequency(freqC: Float, bandwidth: Float) -> (min: Float, max: Float) {
        
        let twoPowerBandwidth = pow(2, bandwidth)
        let min = sqrt((freqC * freqC) / twoPowerBandwidth)
        let max = min * twoPowerBandwidth
        
        return (min, max)
    }
}
