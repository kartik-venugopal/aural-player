//
// ReplayGainUnitViewController+Actions.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import AppKit

extension ReplayGainUnitViewController {
    
    @IBAction func dataSourceAction(_ sender: NSMenuItem) {
        
        replayGainUnit.dataSource = .init(rawValue: sender.tag) ?? .metadataOrAnalysis
        replayGainUnitView.dataSourceUpdated(appliedGain: replayGainUnit.appliedGain, appliedGainType: replayGainUnit.appliedGainType)
    }
    
    @IBAction func maxPeakLevelAction(_ sender: NSMenuItem) {
        
        replayGainUnit.maxPeakLevel = .zero
        replayGainUnitView.zeroMaxPeakLevelSet()
    }
    
    @IBAction func customMaxPeakLevelCheckboxAction(_ sender: CheckBox) {
        replayGainUnitView.customMaxPeakLevelSet()
    }
    
    @IBAction func preAmpAction(_ sender: NSSlider) {
        
        replayGainUnit.preAmp = sender.floatValue
        replayGainUnitView.preAmpUpdated(to: replayGainUnit.preAmp)
    }
    
    @IBAction func preventClippingAction(_ sender: EffectsUnitToggle) {
        
        replayGainUnit.preventClipping = sender.isOn
        
        replayGainUnitView.preventClippingUpdated(isScanning: replayGainUnit.isScanning,
                                                  appliedGain: replayGainUnit.appliedGain,
                                                  appliedGainType: replayGainUnit.appliedGainType)
    }
    
    @IBAction func modeAction(_ sender: NSPopUpButton) {
        
        replayGainUnit.mode = .init(rawValue: sender.selectedTag()) ?? .defaultMode
        
        replayGainUnitView.modeUpdated(appliedGain: replayGainUnit.appliedGain,
                                       appliedGainType: replayGainUnit.appliedGainType,
                                       preAmp: replayGainUnit.preAmp)
    }
}
