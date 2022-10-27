//
//  ParametricEQNode.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation
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

    static let validGainRange: ClosedRange<Float> = -20...20
    
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
    
    var bandGains: [Float] {
        
        get {bands.map {$0.gain}}
        
        set {
            
            var newGains = newValue
            
            if newGains.count == 10 {
                newGains = Self.map10BandsTo15Bands(newGains)
            }
            
            for index in 0..<newGains.count {
                bands[index].gain = newGains[index].clamp(to: Self.validGainRange)
            }
        }
    }
    
    @inline(__always)
    private static func map10BandsTo15Bands(_ srcBands: [Float]) -> [Float] {
        
        var bands = [0, 0, 1, 2, 2, 3, 4, 4, 5, 6, 6, 7, 8, 8, 9].map {srcBands[$0]}
        
        bands[1] = (bands[0] + bands[2]) / 2
        bands[4] = (bands[3] + bands[5]) / 2
        bands[7] = (bands[6] + bands[8]) / 2
        bands[10] = (bands[9] + bands[11]) / 2
        bands[13] = (bands[12] + bands[14]) / 2
        
        return bands
    }
    
    subscript(_ index: Int) -> Float {
        
        get {bands[index].gain}
        set {bands[index].gain = newValue}
    }
    
    func increaseBass(by increment: Float) -> [Float] {
        
        increaseBandGains(atIndices: bassBandIndexes, by: increment)
        return bandGains
    }
    
    func decreaseBass(by decrement: Float) -> [Float] {
        
        decreaseBandGains(atIndices: bassBandIndexes, by: decrement)
        return bandGains
    }
    
    func increaseMids(by increment: Float) -> [Float] {
        
        increaseBandGains(atIndices: midBandIndexes, by: increment)
        return bandGains
    }
    
    func decreaseMids(by decrement: Float) -> [Float] {
        
        decreaseBandGains(atIndices: midBandIndexes, by: decrement)
        return bandGains
    }
    
    func increaseTreble(by increment: Float) -> [Float] {
        
        increaseBandGains(atIndices: trebleBandIndexes, by: increment)
        return bandGains
    }
    
    func decreaseTreble(by decrement: Float) -> [Float] {
        
        decreaseBandGains(atIndices: trebleBandIndexes, by: decrement)
        return bandGains
    }
    
    private func increaseBandGains(atIndices bandIndexes: [Int], by increment: Float) {
        
        bandIndexes.forEach {
            
            let band = bands[$0]
            band.gain = (band.gain + increment).clamp(to: Self.validGainRange)
        }
    }
    
    private func decreaseBandGains(atIndices bandIndexes: [Int], by decrement: Float) {
        
        bandIndexes.forEach {
            
            let band = bands[$0]
            band.gain = (band.gain - decrement).clamp(to: Self.validGainRange)
        }
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
