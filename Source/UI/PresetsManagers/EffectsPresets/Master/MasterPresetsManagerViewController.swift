//
//  MasterPresetsManagerViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class MasterPresetsManagerViewController: EffectsPresetsManagerGenericViewController {

    override var nibName: NSNib.Name? {"MasterPresetsManager"}
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        unitType = .master
        effectsUnit = audioGraphDelegate.masterUnit
        presetsWrapper = PresetsWrapper<MasterPreset, MasterPresets>(audioGraphDelegate.masterUnit.presets)
    }
}
