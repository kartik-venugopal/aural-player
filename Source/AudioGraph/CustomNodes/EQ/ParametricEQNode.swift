//
//  ParametricEQNode.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa
import AVFoundation

///
/// A custom subclass of **AVAudioUnitEQ** that provides convenience functions
/// to the Equalizer effects unit.
///
/// Can contain a variable number of equalizer bands.
///
/// No instances of this type are to be used directly, as this class is only intended to be used as a base
/// class for concrete Equalizer nodes that define a specific number and configuration of bands.
///
/// - SeeAlso: `TenBandEQNode`
/// - SeeAlso: `FifteenBandEQNode`
///
class ParametricEQNode: AVAudioUnitEQ {
    
    var frequencies: [Float] {[]}
    var bandwidth: Float {0}
    
    var bassBandIndexes: [Int] {[]}
    var midBandIndexes: [Int] {[]}
    var trebleBandIndexes: [Int] {[]}
    
    var numberOfBands: Int {bands.count}

    // TODO: Use these values to validate gain values in setBand(index, gain)
    private static let maxGain: Float = 20
    private static let minGain: Float = -20
    
    override private init() {super.init()}
    
    fileprivate init(_ numBands: Int) {
        
        super.init(numberOfBands: numBands)
        initBands()
    }
    
    fileprivate func initBands() {
        
        for (band, frequency) in zip(bands, frequencies) {
            
            band.frequency = frequency
            
            // Constant
            band.bypass = false
            band.filterType = .parametric
            band.bandwidth = bandwidth
        }
    }
    
    func bandAtFrequency(_ freq: Float) -> AVAudioUnitEQFilterParameters? {
        bands.first(where: {$0.frequency == freq})
    }
    
    func increaseBass(_ increment: Float) -> [Float] {
        
        increaseBandGains(bassBandIndexes, increment)
        return bandGains
    }
    
    func decreaseBass(_ decrement: Float) -> [Float] {
        
        decreaseBandGains(bassBandIndexes, decrement)
        return bandGains
    }
    
    func increaseMids(_ increment: Float) -> [Float] {
        
        increaseBandGains(midBandIndexes, increment)
        return bandGains
    }
    
    func decreaseMids(_ decrement: Float) -> [Float] {
        
        decreaseBandGains(midBandIndexes, decrement)
        return bandGains
    }
    
    func increaseTreble(_ increment: Float) -> [Float] {
        
        increaseBandGains(trebleBandIndexes, increment)
        return bandGains
    }
    
    func decreaseTreble(_ decrement: Float) -> [Float] {
        
        decreaseBandGains(trebleBandIndexes, decrement)
        return bandGains
    }
    
    private func increaseBandGains(_ bandIndexes: [Int], _ increment: Float) {
        
        bandIndexes.forEach({
            
            let band = bands[$0]
            band.gain = min(band.gain + increment, Self.maxGain)
        })
    }
    
    private func decreaseBandGains(_ bandIndexes: [Int], _ decrement: Float) {
        
        bandIndexes.forEach({
            
            let band = bands[$0]
            band.gain = max(band.gain - decrement, Self.minGain)
        })
    }
    
    var bandGains: [Float] {
        
        get {bands.map {$0.gain}}
        
        set(newGains) {
            
            for index in 0..<newGains.count {
                bands[index].gain = newGains[index]
            }
        }
    }
    
    subscript(_ index: Int) -> Float {
        
        get {bands[index].gain}
        set {bands[index].gain = newValue}
    }
}

///
/// A specialized **ParametricEQNode** that represents an ISO standard 10-band Equalizer.
///
class TenBandEQNode: ParametricEQNode {
    
    override var frequencies: [Float] {SoundConstants.ISOStandard10BandEQFrequencies}
    override var bandwidth: Float {1}
    
    override var bassBandIndexes: [Int] {[0, 1, 2]}
    override var midBandIndexes: [Int] {[3, 4, 5, 6]}
    override var trebleBandIndexes: [Int] {[7, 8, 9]}
    
    init() {
        super.init(10)
    }
}

///
/// A specialized **ParametricEQNode** that represents an ISO standard 15-band Equalizer.
///
class FifteenBandEQNode: ParametricEQNode {
    
    override var frequencies: [Float] {SoundConstants.ISOStandard15BandEQFrequencies}
    override var bandwidth: Float {2/3}
    
    override var bassBandIndexes: [Int] {[0, 1, 2, 3, 4]}
    override var midBandIndexes: [Int] {[5, 6, 7, 8, 9, 10]}
    override var trebleBandIndexes: [Int] {[11, 12, 13, 14]}
    
    init() {
        super.init(15)
    }
}
