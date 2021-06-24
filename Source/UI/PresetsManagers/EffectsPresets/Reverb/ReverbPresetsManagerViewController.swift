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

class ReverbPresetsManagerViewController: FXPresetsManagerGenericViewController {
    
    @IBOutlet weak var reverbView: ReverbView!
    
    override var nibName: String? {"ReverbPresetsManager"}
    
    var reverbUnit: ReverbUnitDelegateProtocol {graph.reverbUnit}
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        unitType = .reverb
        fxUnit = reverbUnit
        presetsWrapper = PresetsWrapper<ReverbPreset, ReverbPresets>(reverbUnit.presets)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        reverbView.initialize({() -> FXUnitState in .active})
    }
    
    override func renderPreview(_ presetName: String) {
        
        if let preset = reverbUnit.presets.preset(named: presetName) {
            renderPreview(preset)
        }
    }
    
    private func renderPreview(_ preset: ReverbPreset) {
        reverbView.applyPreset(preset)
    }
}
