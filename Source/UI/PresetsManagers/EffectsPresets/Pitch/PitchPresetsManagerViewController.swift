//
//  PitchShiftPresetsManagerViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class PitchShiftPresetsManagerViewController: EffectsPresetsManagerGenericViewController {
    
    @IBOutlet weak var pitchView: PitchView!
    
    override var nibName: String? {"PitchShiftPresetsManager"}
    
    var pitchUnit: PitchShiftUnitDelegateProtocol = ObjectGraph.audioGraphDelegate.pitchUnit
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        unitType = .pitch
        effectsUnit = pitchUnit
        presetsWrapper = PresetsWrapper<PitchShiftPreset, PitchShiftPresets>(pitchUnit.presets)
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()
        pitchView.initialize({() -> EffectsUnitState in .active})
    }
    
    override func renderPreview(_ presetName: String) {
        
        if let preset = pitchUnit.presets.preset(named: presetName) {
            renderPreview(preset)
        }
    }
   
    private func renderPreview(_ preset: PitchShiftPreset) {
        pitchView.applyPreset(preset)
    }
}
