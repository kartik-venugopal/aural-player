//
// MasterUnitProtocol.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

protocol MasterUnitProtocol: EffectsUnitProtocol {
    
    var presets: MasterPresets {get}
    
    func applyPreset(_ preset: MasterPreset)
    
    var settingsAsPreset: MasterPreset {get}
}
