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
            
            setBandParameters(for: updatedBand)
        }
    }
    
    func addBand(_ band: FilterBand) -> Int {
        
        // Should never happen, but for safety
        guard inactiveBands.isNonEmpty else {return -1}
        
        band.params = inactiveBands.removeLast()
        band.params.bypass = false
        setBandParameters(for: band)
        
        bandInfos.append(band)
        return bandInfos.lastIndex
    }
    
    func addBands(_ bands: [FilterBand]) {
        bands.forEach {_ = addBand($0)}
    }
    
    private func setBandParameters(for band: FilterBand) {
        
        guard let params = band.params else {return}
        
        let minFreq = band.minFreq
        let maxFreq = band.maxFreq
        
        switch band.type {
        
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
        
        params.filterType = band.type.toAVFilterType()
        
        if params.filterType == .parametric {
            params.gain = Self.bandStopGain
        }
    }
    
    func removeBands(atIndices indexSet: IndexSet) {
    
        // Descending order
        let sortedIndexes = indexSet.sortedDescending()
        sortedIndexes.forEach {removeBand(at: $0)}
    }
    
    private func removeAllBands() {
        
        bandInfos.forEach {removeBand($0)}
        bandInfos.removeAll()
    }
    
    private func removeBand(at index: Int) {
        
        removeBand(bandInfos[index])
        bandInfos.remove(at: index)
    }
    
    private func removeBand(_ band: FilterBand) {
        
        guard let params = band.params else {return}
        
        params.bypass = true
        inactiveBands.append(params)
    }
}
