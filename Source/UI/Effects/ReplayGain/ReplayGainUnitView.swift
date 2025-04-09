//
// ReplayGainUnitView.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import AppKit

class ReplayGainUnitView: NSView {
    
    @IBOutlet weak var modeMenuButton: NSPopUpButton!
    @IBOutlet weak var modeMenuButtonCell: EffectsUnitPopupMenuCell!
    
    @IBOutlet weak var lblGain: NSTextField!
    
    @IBOutlet weak var preAmpSlider: EffectsUnitSlider!
    @IBOutlet weak var lblPreAmp: NSTextField!
    
    @IBOutlet weak var btnPreventClipping: EffectsUnitToggle!
    
    // ------------------------------------------------------------------------
    
    // MARK: Settings menu items
    
    @IBOutlet weak var dataSourceMenuItem_metadataOrAnalysis: NSMenuItem!
    @IBOutlet weak var dataSourceMenuItem_metadataOnly: NSMenuItem!
    @IBOutlet weak var dataSourceMenuItem_analysisOnly: NSMenuItem!
    
    @IBOutlet weak var maxPeakLevelMenuItem_zero: NSMenuItem!
    @IBOutlet weak var maxPeakLevelSelectorView: DecibelSelectorView!
    
    var unitStateObservers: [FXUnitStateObserver] {
        [modeMenuButtonCell, btnPreventClipping]
    }
    
    func initialize(modeDescription: String, preAmp: Float, isScanning: Bool, preventClipping: Bool, appliedGain: Float?, appliedGainType: ReplayGainType?) {
        
        modeMenuButton.selectItem(withTitle: modeDescription)
        
        preAmpSlider.floatValue = preAmp
        
        if !isScanning {
            updateGainLabel(appliedGain: appliedGain, appliedGainType: appliedGainType)
        }
        
        lblPreAmp.stringValue = String(format: "%.2f dB", preAmp)
        btnPreventClipping.onIf(preventClipping)
    }
    
    func scanInitiated(scanStatus: String?) {
        
        if let scanStatus {
            lblGain.stringValue = scanStatus
        }
    }
    
    func scanCompleted(appliedGain: Float?, appliedGainType: ReplayGainType?) {
        updateGainLabel(appliedGain: appliedGain, appliedGainType: appliedGainType)
    }
    
    func dataSourceUpdated(appliedGain: Float?, appliedGainType: ReplayGainType?) {
        updateGainLabel(appliedGain: appliedGain, appliedGainType: appliedGainType)
    }
    
    func zeroMaxPeakLevelSet() {
        maxPeakLevelSelectorView.setCustomCheckboxState(.off)
    }
    
    func customMaxPeakLevelSet() {
        
        maxPeakLevelSelectorView.setCustomCheckboxState(maxPeakLevelSelectorView.btnCustomDecibel.state)
        maxPeakLevelMenuItem_zero.onIf(maxPeakLevelSelectorView.btnCustomDecibel.isOff)
    }
    
    func preAmpUpdated(to preAmp: Float) {
        lblPreAmp.stringValue = String(format: "%.2f dB", preAmp)
    }
    
    func preventClippingUpdated(isScanning: Bool, appliedGain: Float?, appliedGainType: ReplayGainType?) {
        
        if !isScanning {
            updateGainLabel(appliedGain: appliedGain, appliedGainType: appliedGainType)
        }
    }
    
    func modeUpdated(appliedGain: Float?, appliedGainType: ReplayGainType?, preAmp: Float) {
        
        updateGainLabel(appliedGain: appliedGain, appliedGainType: appliedGainType)
        lblPreAmp.stringValue = String(format: "%.2f dB", preAmp)
    }
    
    private func updateGainLabel(appliedGain: Float?, appliedGainType: ReplayGainType?) {
        
        if let appliedGain, let appliedGainType {
            lblGain.stringValue = "\(String(format: "%.2f", appliedGain)) dB  (\(appliedGainType.description))"
            
        } else {
            lblGain.stringValue = "<None>"
        }
    }
    
    func updateMenu(dataSource: ReplayGainDataSource, maxPeakLevel: ReplayGainMaxPeakLevel) {
        
        [dataSourceMenuItem_metadataOrAnalysis, dataSourceMenuItem_metadataOnly, dataSourceMenuItem_analysisOnly].forEach {
            $0?.off()
        }
        
        switch dataSource {
            
        case .metadataOrAnalysis:
            dataSourceMenuItem_metadataOrAnalysis.on()
            
        case .metadataOnly:
            dataSourceMenuItem_metadataOnly.on()
            
        case .analysisOnly:
            dataSourceMenuItem_analysisOnly.on()
        }
        
        switch maxPeakLevel {
            
        case .zero:
            
            maxPeakLevelMenuItem_zero.on()
            maxPeakLevelSelectorView.setCustomCheckboxState(.off)
            
        case .custom(_):
            
            maxPeakLevelMenuItem_zero.off()
            maxPeakLevelSelectorView.setCustomCheckboxState(.on)
        }
        
        maxPeakLevelSelectorView.prepareToAppear()
    }
}
