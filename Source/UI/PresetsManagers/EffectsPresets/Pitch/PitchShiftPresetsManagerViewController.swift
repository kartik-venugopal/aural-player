//
//  PitchShiftPresetsManagerViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class PitchShiftPresetsManagerViewController: EffectsPresetsManagerGenericViewController {
    
    override var nibName: NSNib.Name? {"PitchShiftPresetsManager"}
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        unitType = .pitch
        effectsUnit = audioGraph.pitchShiftUnit
        presetsWrapper = PresetsWrapper<PitchShiftPreset, PitchShiftPresets>(audioGraph.pitchShiftUnit.presets)
    }
}
