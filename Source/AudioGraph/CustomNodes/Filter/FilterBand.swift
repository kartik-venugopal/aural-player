//
//  FilterBand.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

///
/// Represents a single band of audio frequencies that can be eliminated / passed through
/// by a Filter effects node.
/// 
/// - SeeAlso: `FilterBandType`
///
class FilterBand {
    
    var type: FilterBandType
    
    var minFreq: Float?     // Used for highPass, bandPass, and bandStop
    var maxFreq: Float?     // Used for lowPass, bandPass, and bandStop
    
    var params: AVAudioUnitEQFilterParameters!
    
    init(type: FilterBandType) {
        self.type = type
    }
    
    init(type: FilterBandType, minFreq: Float?, maxFreq: Float?) {
        
        self.type = type
        self.minFreq = minFreq
        self.maxFreq = maxFreq
    }
    
    init?(persistentState: FilterBandPersistentState) {
        
        guard let type = persistentState.type else {return nil}
        self.type = type
        
        self.minFreq = persistentState.minFreq
        self.maxFreq = persistentState.maxFreq
        
        switch type {
        
        case .bandPass, .bandStop:
            
            if self.minFreq == nil || self.maxFreq == nil {return nil}
            
        case .lowPass:
            
            if maxFreq == nil {return nil}
            
        case .highPass:
            
            if minFreq == nil {return  nil}
        }
    }
    
    func clone() -> FilterBand {
        return FilterBand(type: self.type, minFreq: self.minFreq, maxFreq: self.maxFreq)
    }
    
    static func bandPassBand(minFreq: Float, maxFreq: Float) -> FilterBand {
        return FilterBand(type: .bandPass, minFreq: minFreq, maxFreq: maxFreq)
    }
    
    static func bandStopBand(minFreq: Float, maxFreq: Float) -> FilterBand {
        return FilterBand(type: .bandStop, minFreq: minFreq, maxFreq: maxFreq)
    }
    
    static func lowPassBand(maxFreq: Float) -> FilterBand {
        return FilterBand(type: .lowPass, minFreq: nil, maxFreq: maxFreq)
    }
    
    static func highPassBand(minFreq: Float) -> FilterBand {
        return FilterBand(type: .highPass, minFreq: minFreq, maxFreq: nil)
    }
}
