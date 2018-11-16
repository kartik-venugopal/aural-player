/*
    A special case (customized) extension of AVAudioUnitEQ to represent a 10 band parametric equalizer
*/

import Cocoa
import AVFoundation

// Wrapper around ParametricEQNode's (switches between different EQ types)
class ParametricEQ: ParametricEQProtocol {
    
    var eq10Node: ParametricEQNode
    var eq15Node: FifteenBandEQNode
    var sync: Bool
    var allNodes: [ParametricEQNode] { return [eq10Node, eq15Node] }
    
    var bypass: Bool {
        
        didSet {
            activeNode.bypass = self.bypass
        }
    }
    
    var type: EQType
    
    var globalGain: Float {

        get {
            return activeNode.globalGain
        }
        
        set(newGlobalGain) {
            activeNode.globalGain = newGlobalGain
        }
    }
    
    var activeNode: ParametricEQNode {
        return type == .tenBand ? eq10Node : eq15Node
    }
    
    var inactiveNode: ParametricEQNode {
        return type == .tenBand ? eq15Node : eq10Node
    }
    
    init(_ type: EQType, _ sync: Bool) {
        
        eq10Node = ParametricEQNode()
        eq15Node = FifteenBandEQNode()
        
        self.type = type
        self.sync = sync
        self.bypass = false
        self.globalGain = AppDefaults.eqGlobalGain
    }
    
    func chooseType(_ type: EQType) {
        
        if self.type == type {return}
        
        self.type = type
        
        if !self.bypass {
            eq10Node.bypass = type != .tenBand
            eq15Node.bypass = type != .fifteenBand
        }
        
        if sync {
            setBands(inactiveNode.allBands())
            globalGain = inactiveNode.globalGain
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
    
    func setBand(_ index: Int, gain: Float) {
        activeNode.setBand(index, gain: gain)
    }
    
    func setBands(_ allBands: [Float]) {
        
        if allBands.isEmpty {return}
        
        if allBands.count != activeNode.numberOfBands {

            type == .tenBand ? eq10Node.setBands(EQMapper.map15BandsTo10Bands(allBands, eq10Node.frequencies)) : eq15Node.setBands(EQMapper.map10BandsTo15Bands(allBands, eq15Node.frequencies))

        } else {
            activeNode.setBands(allBands)
        }
    }
    
    func allBands() -> [Float] {
        return activeNode.allBands()
    }
}

class ParametricEQNode: AVAudioUnitEQ, ParametricEQProtocol {
    
    var frequencies: [Float] {return AppConstants.eq10BandFrequencies}
    var bandwidth: Float {return 1}
    
    var bassBandIndexes: [Int] {return [0, 1, 2]}
    var midBandIndexes: [Int] {return [3, 4, 5, 6]}
    var trebleBandIndexes: [Int] {return [7, 8, 9]}
    
    var numberOfBands: Int {
        return bands.count
    }
    
    func bandAtFrequency(_ freq: Float) -> AVAudioUnitEQFilterParameters? {
        
        for band in bands {
            if band.frequency == freq {
                return band
            }
        }
        
        return nil
    }
    
    // TODO: Use these values to validate gain values in setBand(index, gain)
    private let maxGain: Float = 20
    private let minGain: Float = -20
    
    override convenience init() {
        self.init(10)
    }
  
    fileprivate init(_ numBands: Int) {
        
        super.init(numberOfBands: numBands)
        initBands()
    }
    
    fileprivate func initBands() {
        
        for i in 0..<numberOfBands {
            
            let band = bands[i]
            
            band.frequency = frequencies[i]
            
            // Constant
            band.bypass = false
            band.filterType = AVAudioUnitEQFilterType.parametric
            band.bandwidth = bandwidth
        }
    }
    
    func increaseBass(_ increment: Float) -> [Float] {
        
        let _ = increaseBandGains(bassBandIndexes, increment)
        return allBands()
    }
    
    func decreaseBass(_ decrement: Float) -> [Float] {
        let _ = decreaseBandGains(bassBandIndexes, decrement)
        return allBands()
    }
    
    func increaseMids(_ increment: Float) -> [Float] {
        let _ = increaseBandGains(midBandIndexes, increment)
        return allBands()
    }
    
    func decreaseMids(_ decrement: Float) -> [Float] {
        let _ = decreaseBandGains(midBandIndexes, decrement)
        return allBands()
    }
    
    func increaseTreble(_ increment: Float) -> [Float] {
        let _ = increaseBandGains(trebleBandIndexes, increment)
        return allBands()
    }
    
    func decreaseTreble(_ decrement: Float) -> [Float] {
        let _ = decreaseBandGains(trebleBandIndexes, decrement)
        return allBands()
    }
    
    private func increaseBandGains(_ bandIndexes: [Int], _ increment: Float) -> [Float] {
        
        var newGainValues = [Float]()
        bandIndexes.forEach({
            
            let band = bands[$0]
            band.gain = min(band.gain + increment, maxGain)
            newGainValues[$0] = band.gain
        })
        
        return newGainValues
    }
    
    private func decreaseBandGains(_ bandIndexes: [Int], _ decrement: Float) -> [Float] {
        
        var newGainValues = [Float]()
        bandIndexes.forEach({
            
            let band = bands[$0]
            band.gain = max(band.gain - decrement, minGain)
            newGainValues[$0] = band.gain
        })
        
        return newGainValues
    }
    
    // Helper function to set gain for a band
    func setBand(_ index: Int, gain: Float) {
        
        if ((0..<numberOfBands).contains(index)) {
            bands[index].gain = gain
        }
    }
    
    // Helper function to set gain for all bands
    func setBands(_ allBands: [Float]) {

        for index in 0..<allBands.count {
            bands[index].gain = allBands[index]
        }
    }
    
    // Frequency -> Gain
    func setBands(_ allBands: [Float: Float]) {
        
        for (freq, gain) in allBands {
            bandAtFrequency(freq)!.gain = gain
        }
    }
    
    func allBands() -> [Float] {
        
        var allBands: [Float] = []
        bands.forEach({allBands.append($0.gain)})
        return allBands
    }
}

class FifteenBandEQNode: ParametricEQNode {
    
    override var frequencies: [Float] {return AppConstants.eq15BandFrequencies}
    override var bandwidth: Float {return 2/3}
    
    override var bassBandIndexes: [Int] {return [0, 1, 2, 3, 4]}
    override var midBandIndexes: [Int] {return [5, 6, 7, 8, 9, 10]}
    override var trebleBandIndexes: [Int] {return [11, 12, 13, 14]}
    
    init() {
        super.init(15)
    }
}

protocol ParametricEQProtocol {
    
    func increaseBass(_ increment: Float) -> [Float]
    
    func decreaseBass(_ decrement: Float) -> [Float]
    
    func increaseMids(_ increment: Float) -> [Float]
    
    func decreaseMids(_ decrement: Float) -> [Float]
    
    func increaseTreble(_ increment: Float) -> [Float]
    
    func decreaseTreble(_ decrement: Float) -> [Float]

    func setBand(_ index: Int, gain: Float)
    
    func setBands(_ allBands: [Float])
    
    func allBands() -> [Float]
}

class EQMapper {
    
    static func map10BandsTo15Bands(_ srcBands: [Float], _ targetFrequencies: [Float]) -> [Float: Float] {
        
        var mappedBands: [Float: Float] = [:]
        
        mappedBands[targetFrequencies[0]] = srcBands[0]
        mappedBands[targetFrequencies[1]] = srcBands[0]
        
        mappedBands[targetFrequencies[2]] = srcBands[1]
        
        mappedBands[targetFrequencies[3]] = srcBands[2]
        mappedBands[targetFrequencies[4]] = srcBands[2]
        
        mappedBands[targetFrequencies[5]] = srcBands[3]
        
        mappedBands[targetFrequencies[6]] = srcBands[4]
        mappedBands[targetFrequencies[7]] = srcBands[4]
        
        mappedBands[targetFrequencies[8]] = srcBands[5]
        
        mappedBands[targetFrequencies[9]] = srcBands[6]
        mappedBands[targetFrequencies[10]] = srcBands[6]
        
        mappedBands[targetFrequencies[11]] = srcBands[7]
        
        mappedBands[targetFrequencies[12]] = srcBands[8]
        mappedBands[targetFrequencies[13]] = srcBands[8]
        
        mappedBands[targetFrequencies[14]] = srcBands[9]
        
        return mappedBands
    }
    
    static func map15BandsTo10Bands(_ srcBands: [Float], _ targetFrequencies: [Float]) -> [Float: Float] {
        
        var mappedBands: [Float: Float] = [:]
        
        mappedBands[targetFrequencies[0]] = (srcBands[0] + srcBands[1]) / 2
        mappedBands[targetFrequencies[1]] = srcBands[2]
        mappedBands[targetFrequencies[2]] = (srcBands[3] + srcBands[4]) / 2
        mappedBands[targetFrequencies[3]] = srcBands[5]
        mappedBands[targetFrequencies[4]] = (srcBands[6] + srcBands[7]) / 2
        mappedBands[targetFrequencies[5]] = srcBands[8]
        mappedBands[targetFrequencies[6]] = (srcBands[9] + srcBands[10]) / 2
        mappedBands[targetFrequencies[7]] = srcBands[11]
        mappedBands[targetFrequencies[8]] = (srcBands[12] + srcBands[13]) / 2
        mappedBands[targetFrequencies[9]] = srcBands[14]

        return mappedBands
    }
}
