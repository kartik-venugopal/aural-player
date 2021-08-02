//
//  ReverbPresetsManagerViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class ReverbPresetsManagerViewController: EffectsPresetsManagerGenericViewController {
    
    @IBOutlet weak var reverbView: ReverbUnitView!
    
    override var nibName: String? {"ReverbPresetsManager"}
    
    var reverbUnit: ReverbUnitDelegateProtocol {graph.reverbUnit}
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        unitType = .reverb
        effectsUnit = reverbUnit
        presetsWrapper = PresetsWrapper<ReverbPreset, ReverbPresets>(reverbUnit.presets)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        reverbView.initialize(stateFunction: {.active})
    }
    
    override func renderPreview(_ presetName: String) {
        
        if let preset = reverbUnit.presets.object(named: presetName) {
            renderPreview(preset)
        }
    }
    
    private func renderPreview(_ preset: ReverbPreset) {
        reverbView.applyPreset(preset)
    }
}
