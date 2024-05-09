//
//  PitchShiftPresetsManagerViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class PitchShiftPresetsManagerViewController: EffectsPresetsManagerGenericViewController {
    
    @IBOutlet weak var pitchView: PitchShiftUnitView!
    
    override var nibName: NSNib.Name? {"PitchShiftPresetsManager"}
    
    var pitchShiftUnit: PitchShiftUnitDelegateProtocol = audioGraphDelegate.pitchShiftUnit
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        unitType = .pitch
        effectsUnit = pitchShiftUnit
        presetsWrapper = PresetsWrapper<PitchShiftPreset, PitchShiftPresets>(pitchShiftUnit.presets)
    }
    
    override func renderPreview(_ presetName: String) {
        
        if let preset = pitchShiftUnit.presets.object(named: presetName) {
            renderPreview(preset)
        }
    }
   
    private func renderPreview(_ preset: PitchShiftPreset) {
        pitchView.applyPreset(preset)
    }
}
