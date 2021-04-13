/*
    A special (customized) extension of AVAudioUnitEQ to represent a 3-band band-stop filter, with bands for bass, mid, and treble frequency ranges. This is implemented as a 3-band parametric EQ with very low gain (performs more attenuation than an equivalent band-stop filter).
*/

import Foundation
import AVFoundation

class FlexibleFilterNode: AVAudioUnitEQ, FilterNodeProtocol {
    
    static let bandStopGain: Float = -30
    
    var numberOfBands: Int {return bandInfos.count}
    
    var inactiveBands: [AVAudioUnitEQFilterParameters] = []
    
    var bandInfos: [FilterBand] = []
    
    override init() {
        
        super.init(numberOfBands: 31)
        
        bands.forEach({
            $0.bypass = true
            inactiveBands.append($0)
        })
    }
    
    func addBands(_ bands: [FilterBand]) {
        bands.forEach({_ = addBand($0)})
    }
    
    func setBands(_ bands: [FilterBand]) {
        removeAllBands()
        addBands(bands)
    }
    
    func addBand(_ band: FilterBand) -> Int {
        
        // Should never happen, but for safety
        if (inactiveBands.isEmpty) {
            return -1
        }
        
        band.params = inactiveBands.removeLast()
        
        bandInfos.append(band)
        activateBand(band)
        
        return numberOfBands - 1
    }
    
    private func activateBand(_ info: FilterBand) {
        
        setBandParameters(info)
        info.params.bypass = false
    }
    
    private func setBandParameters(_ info: FilterBand) {
        
        let minFreq = info.minFreq
        let maxFreq = info.maxFreq
        
        let params = info.params!
        
        switch info.type {
        
        case .bandPass, .bandStop:
            
            // Frequency at the center of the band is the geometric mean of the min and max frequencies
            let centerFrequency = sqrt(minFreq! * maxFreq!)
            
            // Bandwidth in octaves is the log of the ratio of max to min
            // Ex: If min=200 and max=800, bandwidth = 2 octaves (200 to 400, and 400 to 800)
            let bandwidth = log2(maxFreq! / minFreq!)
            
            params.frequency = centerFrequency
            params.bandwidth = bandwidth
            
        case .lowPass:
            
            params.frequency = maxFreq!
            
        case .highPass:
            
            params.frequency = minFreq!
        }
        
        params.filterType = info.type.toAVFilterType()
        
        if params.filterType == .parametric {params.gain = FlexibleFilterNode.bandStopGain}
    }
    
    func updateBand(_ index: Int, _ band: FilterBand) {
        
        let updatedBand = bandInfos[index]
        
        updatedBand.type = band.type
        updatedBand.minFreq = band.minFreq
        updatedBand.maxFreq = band.maxFreq
        
        setBandParameters(updatedBand)
    }
    
    func removeBands(_ indexSet: IndexSet) {
    
        // Descending order
        let sortedIndexes = indexSet.sorted(by: {i1, i2 -> Bool in return i1 > i2})
        sortedIndexes.forEach({removeBand($0)})
    }
    
    func removeAllBands() {
        
        bandInfos.forEach({
            removeBand($0)
        })
        bandInfos.removeAll()
    }
    
    private func removeBand(_ index: Int) {
        
        let info = bandInfos[index]
        removeBand(info)
        bandInfos.remove(at: index)
    }
    
    private func removeBand(_ info: FilterBand) {
        
        let params = info.params!
        params.bypass = true
        inactiveBands.append(params)
    }
    
    func allBands() -> [FilterBand] {
        return bandInfos
    }
    
    func getBand(_ index: Int) -> FilterBand {
        return bandInfos[index]
    }
}

class FilterBand {
    
    var type: FilterBandType
    
    var minFreq: Float?     // Used for highPass, bandPass, and bandStop
    var maxFreq: Float?     // Used for lowPass, bandPass, and bandStop
    
    fileprivate var params: AVAudioUnitEQFilterParameters!
    
    init(_ type: FilterBandType) {
        self.type = type
    }
    
    init(_ type: FilterBandType, _ minFreq: Float?, _ maxFreq: Float?) {
        
        self.type = type
        self.minFreq = minFreq
        self.maxFreq = maxFreq
    }
    
    func withMinFreq(_ freq: Float) -> FilterBand {
        self.minFreq = freq
        return self
    }
    
    func withMaxFreq(_ freq: Float) -> FilterBand {
        self.maxFreq = freq
        return self
    }
    
    func clone() -> FilterBand {
        return FilterBand(self.type, self.minFreq, self.maxFreq)
    }
    
    static func bandPassBand(_ minFreq: Float, _ maxFreq: Float) -> FilterBand {
        return FilterBand(.bandPass, minFreq, maxFreq)
    }
    
    static func bandStopBand(_ minFreq: Float, _ maxFreq: Float) -> FilterBand {
        return FilterBand(.bandStop, minFreq, maxFreq)
    }
}

protocol FilterNodeProtocol {
    
    func addBand(_ band: FilterBand) -> Int
    
    func updateBand(_ index: Int, _ band: FilterBand)
    
    func removeBands(_ indexSet: IndexSet)
    
    func removeAllBands()
    
    func allBands() -> [FilterBand]
    
    func getBand(_ index: Int) -> FilterBand
}

enum FilterBandType: String {
    
    case bandStop
    case bandPass
    case lowPass
    case highPass
    
    func toAVFilterType() -> AVAudioUnitEQFilterType {
        
        switch self {
            
        case .bandPass: return .bandPass
            
        case .bandStop: return .parametric
            
        case .lowPass: return .lowPass
            
        case .highPass: return .highPass
            
        }
    }
    
    var description: String {
        
        switch self {
            
        case .bandPass: return "Band pass"
            
        case .bandStop: return "Band stop"
            
        case .lowPass: return "Low pass"
            
        case .highPass: return "High pass"
            
        }
    }
    
    // Constructs a ReverPresets object from a description string
    static func fromDescription(_ description: String) -> FilterBandType {
        return FilterBandType(rawValue: StringUtils.camelCase(description))!
    }
}
