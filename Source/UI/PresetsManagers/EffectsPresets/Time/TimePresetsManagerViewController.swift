//
//  TimePresetsManagerViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class TimePresetsManagerViewController: FXPresetsManagerGenericViewController {
    
    @IBOutlet weak var timeView: TimeView!
    
    override var nibName: String? {"TimePresetsManager"}
    
    var timeUnit: TimeUnitDelegateProtocol = ObjectGraph.audioGraphDelegate.timeUnit
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        unitType = .time
        fxUnit = timeUnit
        presetsWrapper = PresetsWrapper<TimePreset, TimePresets>(timeUnit.presets)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        timeView.initialize({() -> FXUnitState in .active})
    }
    
    override func renderPreview(_ presetName: String) {

        if let preset = timeUnit.presets.preset(named: presetName) {
            renderPreview(preset)
        }
    }
    
    private func renderPreview(_ preset: TimePreset) {
        timeView.applyPreset(preset)
    }
}
