//
//  ParametricEQ.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// Wrapper around multiple **ParametricEQNode** instances
///
/// Provides 2 main functions:
/// 1. Switching between different Equalizer types (eg. 10 band and 15 band).
/// 2. Mapping band gains between different Equalizer types (required whenever switching).
///
class ParametricEQ {
    
    var eq10Node: TenBandEQNode
    var eq15Node: FifteenBandEQNode
    var allNodes: [ParametricEQNode] {[eq10Node, eq15Node]}
    
    var bypass: Bool {
        didSet {activeNode.bypass = self.bypass}
    }
    
    var type: EQType {
        
        didSet {
            
            // Hand off properties from the inactive node to the active node.
            
            bands = inactiveNode.bandGains
            globalGain = inactiveNode.globalGain
            
            if !self.bypass {
                
                eq10Node.bypass = type != .tenBand
                eq15Node.bypass = type != .fifteenBand
            }
        }
    }
    
    var globalGain: Float {

        get {activeNode.globalGain}
        set(newGlobalGain) {activeNode.globalGain = newGlobalGain}
    }
    
    var activeNode: ParametricEQNode {type == .tenBand ? eq10Node : eq15Node}
    
    var inactiveNode: ParametricEQNode {type == .tenBand ? eq15Node : eq10Node}
    
    init(type: EQType) {
        
        eq10Node = TenBandEQNode()
        eq15Node = FifteenBandEQNode()
        
        self.type = type
        self.bypass = false
        self.globalGain = AudioGraphDefaults.eqGlobalGain
    }
    
    var bands: [Float] {
        
        get {activeNode.bandGains}
        
        set(newBandGains) {
            
            if newBandGains.count != activeNode.numberOfBands {

                if type == .tenBand {
                    eq10Node.bandGains = Self.map15BandsTo10Bands(newBandGains)
                } else {
                    eq15Node.bandGains = Self.map10BandsTo15Bands(newBandGains)
                }

            } else {
                activeNode.bandGains = newBandGains
            }
        }
    }
    
    // Returns the gain of the band at the given index.
    subscript(_ index: Int) -> Float {
        
        get {activeNode[index]}
        set {activeNode[index] = newValue}
    }
    
    // Pass-through functions
    
    func increaseBass(by increment: Float) -> [Float] {
        return activeNode.increaseBass(by: increment)
    }
    
    func decreaseBass(by decrement: Float) -> [Float] {
        return activeNode.decreaseBass(by: decrement)
    }
    
    func increaseMids(by increment: Float) -> [Float] {
        return activeNode.increaseMids(by: increment)
    }
    
    func decreaseMids(by decrement: Float) -> [Float] {
        return activeNode.decreaseMids(by: decrement)
    }
    
    func increaseTreble(by increment: Float) -> [Float] {
        return activeNode.increaseTreble(by: increment)
    }
    
    func decreaseTreble(by decrement: Float) -> [Float] {
        return activeNode.decreaseTreble(by: decrement)
    }
    
    // MARK: Static utility functions ----------------------------------
    
    static func map10BandsTo15Bands(_ srcBands: [Float]) -> [Float] {
        [0, 0, 1, 2, 2, 3, 4, 4, 5, 6, 6, 7, 8, 8, 9].map {srcBands[$0]}
    }
    
    static func map15BandsTo10Bands(_ srcBands: [Float]) -> [Float] {
        
        [
            (srcBands[0] + srcBands[1]) / 2,
            srcBands[2],
            (srcBands[3] + srcBands[4]) / 2,
            srcBands[5],
            (srcBands[6] + srcBands[7]) / 2,
            srcBands[8],
            (srcBands[9] + srcBands[10]) / 2,
            srcBands[11],
            (srcBands[12] + srcBands[13]) / 2,
            srcBands[14]
        ]
    }
}
