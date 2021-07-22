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
    
    @IBOutlet weak var pitchView: PitchShiftUnitView!
    
    override var nibName: String? {"PitchShiftPresetsManager"}
    
    var pitchShiftUnit: PitchShiftUnitDelegateProtocol = objectGraph.audioGraphDelegate.pitchShiftUnit
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        unitType = .pitch
        effectsUnit = pitchShiftUnit
        presetsWrapper = PresetsWrapper<PitchShiftPreset, PitchShiftPresets>(pitchShiftUnit.presets)
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()
        pitchView.initialize({() -> EffectsUnitState in .active})
    }
    
    override func renderPreview(_ presetName: String) {
        
        if let preset = pitchShiftUnit.presets.preset(named: presetName) {
            renderPreview(preset)
        }
    }
   
    private func renderPreview(_ preset: PitchShiftPreset) {
        pitchView.applyPreset(preset)
    }
}
