//
//  DelayPresetsManagerViewController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class DelayPresetsManagerViewController: EffectsPresetsManagerGenericViewController {
    
    @IBOutlet weak var delayView: DelayUnitView!
    
    override var nibName: String? {"DelayPresetsManager"}
    
    var delayUnit: DelayUnitDelegateProtocol = objectGraph.audioGraphDelegate.delayUnit
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        unitType = .delay
        effectsUnit = delayUnit
        presetsWrapper = PresetsWrapper<DelayPreset, DelayPresets>(delayUnit.presets)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        delayView.initialize(stateFunction: {.active})
    }
    
    override func renderPreview(_ presetName: String) {
        
        if let preset = delayUnit.presets.object(named: presetName) {
            renderPreview(preset)
        }
    }
    
    private func renderPreview(_ preset: DelayPreset) {
        delayView.applyPreset(preset)
    }
}
