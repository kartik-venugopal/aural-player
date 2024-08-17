//
//  ReplayGainUnitProtocol.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

protocol ReplayGainUnitProtocol: EffectsUnitProtocol {
    
    var mode: ReplayGainMode {get set}
    
    // TODO: Maybe allow the user to specify whether to reset the pre-amp when no replay gain metadata is available ???
    
    var replayGain: ReplayGain? {get set}
    
    var preAmp: Float {get set}
    
    var appliedGain: Float {get}
    
    var effectiveGain: Float {get}
}

enum ReplayGainMode: Int, Codable {
    
    case albumGain, trackGain
    
    static let defaultMode: ReplayGainMode = .albumGain
    
    var description: String {
        
        switch self {
            
        case .albumGain:
            return "Album gain"
            
        case .trackGain:
            return "Track gain"
        }
    }
    
    static func fromDescription(_ description: String) -> ReplayGainMode? {
        
        switch description {
            
        case "Album gain":
            return .albumGain
            
        case "Track gain":
            return .trackGain
            
        default:
            return nil
        }
    }
}
