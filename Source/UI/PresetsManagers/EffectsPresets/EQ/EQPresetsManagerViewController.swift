//
//  EQPresetsManagerViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class EQPresetsManagerViewController: EffectsPresetsManagerGenericViewController {
    
    @IBOutlet weak var eqView: EQUnitView!
    
    override var nibName: String? {"EQPresetsManager"}
    
    var eqUnit: EQUnitDelegateProtocol {graph.eqUnit}
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        unitType = .eq
        effectsUnit = eqUnit
        presetsWrapper = PresetsWrapper<EQPreset, EQPresets>(eqUnit.presets)
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        eqView.initialize(eqStateFunction: {.active}, sliderAction: nil, sliderActionTarget: nil)
        eqView.chooseType(.tenBand)
    }
    
    @IBAction func chooseEQTypeAction(_ sender: AnyObject) {
        
        if let preset = firstSelectedPreset as? EQPreset {
            eqView.typeChanged(bands: preset.bands, globalGain: preset.globalGain)
        }
    }
    
    override func renderPreview(_ presetName: String) {
        
        if let preset = eqUnit.presets.object(named: presetName) {
            renderPreview(preset)
        }
    }
    
    private func renderPreview(_ preset: EQPreset) {
        eqView.applyPreset(preset)
    }
}
