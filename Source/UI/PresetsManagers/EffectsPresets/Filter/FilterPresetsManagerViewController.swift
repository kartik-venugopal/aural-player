//
//  FilterPresetsManagerViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class FilterPresetsManagerViewController: EffectsPresetsManagerGenericViewController {
    
    override var nibName: NSNib.Name? {"FilterPresetsManager"}
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        unitType = .filter
        effectsUnit = audioGraph.filterUnit
        presetsWrapper = PresetsWrapper<FilterPreset, FilterPresets>(audioGraph.filterUnit.presets)
    }
}
