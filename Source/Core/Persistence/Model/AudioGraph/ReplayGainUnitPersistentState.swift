//
//  ReplayGainUnitPersistentState.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

struct ReplayGainUnitPersistentState: Codable {
    
    let state: EffectsUnitState?
    let userPresets: [ReplayGainPresetPersistentState]?
    let currentPresetName: String?
    let renderQuality: Int?
    
    let mode: ReplayGainMode?
    let preAmp: Float?
    let preventClipping: Bool?

    let dataSource: ReplayGainDataSource?
    let maxPeakLevel: ReplayGainMaxPeakLevel?
    
    init(state: EffectsUnitState?, userPresets: [ReplayGainPresetPersistentState]?, currentPresetName: String?, renderQuality: Int?, mode: ReplayGainMode?, preAmp: Float?, preventClipping: Bool?, dataSource: ReplayGainDataSource?, maxPeakLevel: ReplayGainMaxPeakLevel?) {
        
        self.state = state
        self.userPresets = userPresets
        self.currentPresetName = currentPresetName
        self.renderQuality = renderQuality
        
        self.mode = mode
        self.preAmp = preAmp
        self.preventClipping = preventClipping
        
        self.dataSource = dataSource
        self.maxPeakLevel = maxPeakLevel
    }
}

struct ReplayGainPresetPersistentState: Codable {
    
    let name: String?
    let state: EffectsUnitState?
    
    let mode: ReplayGainMode?
    let preAmp: Float?
    let preventClipping: Bool?
    
    init(preset: ReplayGainPreset) {
        
        self.name = preset.name
        self.state = preset.state
        
        self.mode = preset.mode
        self.preAmp = preset.preAmp
        self.preventClipping = preset.preventClipping
    }
}

struct ReplayGainAnalysisCachePersistentState: Codable {
    
    let trackGainCache: [URL: ReplayGain]?
    let albumGainCache: [String: AlbumReplayGain]?
}
