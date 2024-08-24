//
//  ReplayGainUnitProtocol.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
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
    
    var preventClipping: Bool {get set}
    
    var appliedGain: Float? {get}
    
    var appliedGainType: ReplayGainType? {get}
    
    var effectiveGain: Float {get}
    
    var dataSource: ReplayGainDataSource {get set}
    
    var maxPeakLevel: ReplayGainMaxPeakLevel {get set}
    
    /*
     
     TODO:
     
     1 - Source (metadata / analysis)
     2 - Configurable target loudness (-18 dB default)
     3 - Configurable peak level (0 db default)
     
     */
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

enum ReplayGainType {
    
    case albumGain, trackGain
    
    var description: String {
        self == .albumGain ? "Album gain" : "Track gain"
    }
}

enum ReplayGainDataSource: Int, Codable {
    
    case metadataOrAnalysis, metadataOnly, analysisOnly
}

enum ReplayGainMaxPeakLevel: Codable {
    
    case zero, custom(maxPeakLevel: Float)
    
    var decibels: Float {
        
        switch self {
            
        case .zero:
            return 0
            
        case .custom(let customDecibels):
            return customDecibels
        }
    }
}
