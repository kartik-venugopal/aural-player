//
//  TimeStretchPresetsManagerViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class TimeStretchPresetsManagerViewController: EffectsPresetsManagerGenericViewController {
    
    @IBOutlet weak var timeView: TimeStretchView!
    
    override var nibName: String? {"TimeStretchPresetsManager"}
    
    var timeStretchUnit: TimeStretchUnitDelegateProtocol = ObjectGraph.audioGraphDelegate.timeStretchUnit
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        unitType = .time
        effectsUnit = timeStretchUnit
        presetsWrapper = PresetsWrapper<TimeStretchPreset, TimeStretchPresets>(timeStretchUnit.presets)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        timeView.initialize({() -> EffectsUnitState in .active})
    }
    
    override func renderPreview(_ presetName: String) {

        if let preset = timeStretchUnit.presets.preset(named: presetName) {
            renderPreview(preset)
        }
    }
    
    private func renderPreview(_ preset: TimeStretchPreset) {
        timeView.applyPreset(preset)
    }
}
