//
//  DelayPresetsManagerViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class DelayPresetsManagerViewController: EffectsPresetsManagerGenericViewController {
    
    override var nibName: NSNib.Name? {"DelayPresetsManager"}
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        unitType = .delay
        effectsUnit = audioGraph.delayUnit
        presetsWrapper = PresetsWrapper<DelayPreset, DelayPresets>(audioGraph.delayUnit.presets)
    }
}
