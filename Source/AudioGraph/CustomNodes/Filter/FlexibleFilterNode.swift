//
//  FlexibleFilterNode.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

///
/// A special (customized) subclass of **AVAudioUnitEQ** to represent a filter effects node
/// with up to 31 bands. By default, the node will have 0 active bands (i.e. all bands will be bypassed.
/// Bands can be added (activated) one by one.
///
/// - SeeAlso: `FilterBand`
/// - SeeAlso: `FilterBandType`
///
class FlexibleFilterNode: AVAudioUnitEQ {
    
    static let bandStopGain: Float = -30
    
    var numberOfBands: Int {bandInfos.count}
    
    var inactiveBands: [AVAudioUnitEQFilterParameters] = []
    
    var bandInfos: [FilterBand] = []
    
    override init() {
        
        super.init(numberOfBands: 31)
        
        bands.forEach {
            
            $0.bypass = true
            inactiveBands.append($0)
        }
    }
    
    var activeBands: [FilterBand] {
        
        get {bandInfos}
        
        set(newBands) {
            
            removeAllBands()
            addBands(newBands)
        }
    }
    
    subscript(_ index: Int) -> FilterBand {
        
        get {bandInfos[index]}
        
        set(newBand) {
            
            let updatedBand = bandInfos[index]
            
            updatedBand.type = newBand.type
            updatedBand.minFreq = newBand.minFreq
            updatedBand.maxFreq = newBand.maxFreq
            
            setBandParameters(updatedBand)
        }
    }
    
    func addBand(_ band: FilterBand) -> Int {
        
        // Should never happen, but for safety
        if inactiveBands.isEmpty {
            return -1
        }
        
        band.params = inactiveBands.removeLast()
        
        bandInfos.append(band)
        activateBand(band)
        
        return bandInfos.lastIndex
    }
    
    func addBands(_ bands: [FilterBand]) {
        bands.forEach {_ = addBand($0)}
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
            
            guard let minFreq = minFreq, let maxFreq = maxFreq else {break}
            
            // Frequency at the center of the band is the geometric mean of the min and max frequencies
            let centerFrequency = sqrt(minFreq * maxFreq)
            
            // Bandwidth in octaves is the log of the ratio of max to min
            // Ex: If min=200 and max=800, bandwidth = 2 octaves (200 to 400, and 400 to 800)
            let bandwidth = log2(maxFreq / minFreq)
            
            params.frequency = centerFrequency
            params.bandwidth = bandwidth
            
        case .lowPass:
            
            if let freq = maxFreq {
                params.frequency = freq
            }
            
        case .highPass:
            
            if let freq = minFreq {
                params.frequency = freq
            }
        }
        
        params.filterType = info.type.toAVFilterType()
        
        if params.filterType == .parametric {
            params.gain = FlexibleFilterNode.bandStopGain
        }
    }
    
    func removeBands(_ indexSet: IndexSet) {
    
        // Descending order
        let sortedIndexes = indexSet.sorted(by: Int.descendingIntComparator)
        sortedIndexes.forEach {removeBand($0)}
    }
    
    func removeAllBands() {
        
        bandInfos.forEach {removeBand($0)}
        bandInfos.removeAll()
    }
    
    private func removeBand(_ index: Int) {
        
        removeBand(bandInfos[index])
        bandInfos.remove(at: index)
    }
    
    private func removeBand(_ info: FilterBand) {
        
        guard let params = info.params else {return}
        
        params.bypass = true
        inactiveBands.append(params)
    }
}
