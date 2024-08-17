//
//  ReplayGainNode.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AVFoundation

///
/// A custom subclass of **AVAudioUnitEQ** that applies a "ReplayGain" effect through its "replayGain" and "preAmp" properties.
///
class ReplayGainNode: AVAudioUnitEQ {
    
    static let validGainRange: ClosedRange<Float> = -20...20
    
    override init() {super.init(numberOfBands: 0)}
    
    fileprivate init(_ numBands: Int) {
        super.init(numberOfBands: 0)
    }
    
    override var globalGain: Float {
        
        get {super.globalGain}
        
        // globalGain cannot be set externally
        set {}
    }
    
    var replayGain: Float = 0 {
        
        didSet {
            super.globalGain = (replayGain + preAmp).clamped(to: Self.validGainRange)
        }
    }
    
    var preAmp: Float = 0 {
        
        didSet {
            super.globalGain = (replayGain + preAmp).clamped(to: Self.validGainRange)
        }
    }
}
