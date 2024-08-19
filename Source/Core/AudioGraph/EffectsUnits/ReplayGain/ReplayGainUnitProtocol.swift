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
    
    case preferAlbumGain, preferTrackGain, trackGainOnly
    
    static let defaultMode: ReplayGainMode = .preferAlbumGain
    
    var description: String {
        
        switch self {
            
        case .preferAlbumGain:
            return "Album gain (or Track gain)"
            
        case .preferTrackGain:
            return "Track gain (or Album gain)"
            
        case .trackGainOnly:
            return "Track gain only"
        }
    }
}
