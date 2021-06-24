//
//  PitchPresetsManagerViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class PitchPresetsManagerViewController: FXPresetsManagerGenericViewController {
    
    @IBOutlet weak var pitchView: PitchView!
    
    override var nibName: String? {"PitchPresetsManager"}
    
    var pitchUnit: PitchUnitDelegateProtocol = ObjectGraph.audioGraphDelegate.pitchUnit
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        unitType = .pitch
        fxUnit = pitchUnit
        presetsWrapper = PresetsWrapper<PitchPreset, PitchPresets>(pitchUnit.presets)
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()
        pitchView.initialize({() -> FXUnitState in .active})
    }
    
    override func renderPreview(_ presetName: String) {
        
        if let preset = pitchUnit.presets.preset(named: presetName) {
            renderPreview(preset)
        }
    }
   
    private func renderPreview(_ preset: PitchPreset) {
        pitchView.applyPreset(preset)
    }
}
