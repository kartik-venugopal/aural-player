//
//  FilterBandType.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import AVFoundation

///
/// An enumeration of all possible filter band types.
///
enum FilterBandType: String, CaseIterable, Codable {
    
    // TODO: [LOW] Look into adding more filter types (lowShelf, highShelf, resonantLowPass/HighPass, etc).
    
    case bandStop
    case bandPass
    case lowPass
    case highPass
    
    func toAVFilterType() -> AVAudioUnitEQFilterType {
        
        switch self {
            
        case .bandPass: return .bandPass
            
        case .bandStop: return .parametric
            
        case .lowPass: return .lowPass
            
        case .highPass: return .highPass
            
        }
    }
    
    var description: String {
        
        switch self {
            
        case .bandPass: return "Band pass"
            
        case .bandStop: return "Band stop"
            
        case .lowPass: return "Low pass"
            
        case .highPass: return "High pass"
            
        }
    }
    
    // Constructs a FilterBAndType object from a description string.
    static func fromDescription(_ description: String) -> FilterBandType {
        return FilterBandType(rawValue: description.camelCased()) ?? .bandStop
    }
}
