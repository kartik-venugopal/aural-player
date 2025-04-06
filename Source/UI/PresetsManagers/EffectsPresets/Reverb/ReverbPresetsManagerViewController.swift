//
//  ReverbPresetsManagerViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class ReverbPresetsManagerViewController: EffectsPresetsManagerGenericViewController {
    
    override var nibName: NSNib.Name? {"ReverbPresetsManager"}
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        unitType = .reverb
        effectsUnit = audioGraph.reverbUnit
        presetsWrapper = PresetsWrapper<ReverbPreset, ReverbPresets>(audioGraph.reverbUnit.presets)
    }
}
