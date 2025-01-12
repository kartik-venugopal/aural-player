//
//  EQPresetsManagerViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class EQPresetsManagerViewController: EffectsPresetsManagerGenericViewController {
    
    override var nibName: NSNib.Name? {"EQPresetsManager"}
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        unitType = .eq
        effectsUnit = audioGraphDelegate.eqUnit
        presetsWrapper = PresetsWrapper<EQPreset, EQPresets>(audioGraphDelegate.eqUnit.presets)
    }
}
