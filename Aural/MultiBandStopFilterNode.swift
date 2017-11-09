/*
    A special (customized) extension of AVAudioUnitEQ to represent a 3-band band-stop filter, with bands for bass, mid, and treble frequency ranges. This is implemented as a 3-band parametric EQ with very low gain (performs more attenuation than an equivalent band-stop filter).
*/

import Cocoa
import AVFoundation

class MultiBandStopFilterNode: AVAudioUnitEQ {
    
    static let bandStopGain: Float = -24
    static let minBandwidth: Float = 0.05
    
    var bassBand: AVAudioUnitEQFilterParameters {
        return bands.first!
    }
    
    var midBand: AVAudioUnitEQFilterParameters {
        return bands[1]
    }
    
    var trebleBand: AVAudioUnitEQFilterParameters {
        return bands[2]
    }
    
    override init() {
        
        super.init(numberOfBands: 3)
        
        for band in bands {
            band.filterType = AVAudioUnitEQFilterType.parametric
            band.bandwidth = MultiBandStopFilterNode.minBandwidth
            band.gain = MultiBandStopFilterNode.bandStopGain
        }
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
        
        // If calculated bandwidth <= min, set bypass to true (bandwidth is negligible)
        let bypassBand: Bool = bandwidth <= MultiBandStopFilterNode.minBandwidth
        
        band.frequency = centerFrequency
        band.bandwidth = bandwidth
        band.bypass = bypassBand
    }

    // Sets the range of frequencies to be attenuated, within the bass frequency band
    func setFilterBassBand(_ min: Float, _ max: Float) {
        setBand(bassBand, min, max)
    }

    // Sets the range of frequencies to be attenuated, within the mid frequency band
    func setFilterMidBand(_ min: Float, _ max: Float) {
        setBand(midBand, min, max)
    }
    
    // Sets the range of frequencies to be attenuated, within the treble frequency band
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
    
    // Calculates the min and max of a frequency range, given the center and bandwidth (inverse of the calculation in setBand())
    private func calcMinMaxForCenterFrequency(freqC: Float, bandwidth: Float) -> (min: Float, max: Float) {
        
        let twoPowerBandwidth = pow(2, bandwidth)
        let min = sqrt((freqC * freqC) / twoPowerBandwidth)
        let max = min * twoPowerBandwidth
        
        return (min, max)
    }
}
