//
//  FilterBand.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
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
    
    init(_ type: FilterBandType) {
        self.type = type
    }
    
    init(_ type: FilterBandType, _ minFreq: Float?, _ maxFreq: Float?) {
        
        self.type = type
        self.minFreq = minFreq
        self.maxFreq = maxFreq
    }
    
    init(persistentState: FilterBandPersistentState) {
        
        self.type = persistentState.type
        self.minFreq = persistentState.minFreq
        self.maxFreq = persistentState.maxFreq
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
    
    static func lowPassBand(_ maxFreq: Float) -> FilterBand {
        return FilterBand(.lowPass, nil, maxFreq)
    }
    
    static func highPassBand(_ minFreq: Float) -> FilterBand {
        return FilterBand(.lowPass, minFreq, nil)
    }
}
