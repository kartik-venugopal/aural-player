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
    
    var type: EQType
    
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
    
    func chooseType(_ type: EQType) {
        
        if self.type == type {return}
        
        self.type = type
        
        // Handoff band gains from the inactive node to the active node
        bands = inactiveNode.bandGains
        globalGain = inactiveNode.globalGain
        
        if !self.bypass {
            eq10Node.bypass = type != .tenBand
            eq15Node.bypass = type != .fifteenBand
        }
    }
    
    // Pass-through functions
    
    func increaseBass(_ increment: Float) -> [Float] {
        return activeNode.increaseBass(increment)
    }
    
    func decreaseBass(_ decrement: Float) -> [Float] {
        return activeNode.decreaseBass(decrement)
    }
    
    func increaseMids(_ increment: Float) -> [Float] {
        return activeNode.increaseMids(increment)
    }
    
    func decreaseMids(_ decrement: Float) -> [Float] {
        return activeNode.decreaseMids(decrement)
    }
    
    func increaseTreble(_ increment: Float) -> [Float] {
        return activeNode.increaseTreble(increment)
    }
    
    func decreaseTreble(_ decrement: Float) -> [Float] {
        return activeNode.decreaseTreble(decrement)
    }
    
    // MARK: Static utility functions ----------------------------------
    
    static func map10BandsTo15Bands(_ srcBands: [Float]) -> [Float] {
        
        [srcBands[0], srcBands[0], srcBands[1], srcBands[2], srcBands[2], srcBands[3], srcBands[4],
         srcBands[4], srcBands[5], srcBands[6], srcBands[6], srcBands[7], srcBands[8], srcBands[8], srcBands[9]]
    }
    
    static func map15BandsTo10Bands(_ srcBands: [Float]) -> [Float] {
        
        var mappedBands: [Float] = []
        
        mappedBands.append((srcBands[0] + srcBands[1]) / 2)
        mappedBands.append(srcBands[2])
        mappedBands.append((srcBands[3] + srcBands[4]) / 2)
        mappedBands.append(srcBands[5])
        mappedBands.append((srcBands[6] + srcBands[7]) / 2)
        mappedBands.append(srcBands[8])
        mappedBands.append((srcBands[9] + srcBands[10]) / 2)
        mappedBands.append(srcBands[11])
        mappedBands.append((srcBands[12] + srcBands[13]) / 2)
        mappedBands.append(srcBands[14])

        return mappedBands
    }
}
