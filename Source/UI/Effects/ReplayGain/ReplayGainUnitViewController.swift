//
//  ReplayGainUnitViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class ReplayGainUnitViewController: EffectsUnitViewController {
    
    override var nibName: NSNib.Name? {"ReplayGainUnit"}
    
    // ------------------------------------------------------------------------
    
    // MARK: UI fields
    
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
    
    // -------------
    
    // MARK: Services, utilities, helpers, and properties
    
    private var replayGainUnit: ReplayGainUnitDelegateProtocol = audioGraphDelegate.replayGainUnit
    
    // ------------------------------------------------------------------------
    
    // MARK: UI initialization / life-cycle
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        self.effectsUnit = graph.replayGainUnit
        self.presetsWrapper = PresetsWrapper<ReplayGainPreset, ReplayGainPresets>(audioGraph.replayGainUnit.presets)
        
        fxUnitStateObserverRegistry.registerObserver(modeMenuButtonCell, forFXUnit: graph.replayGainUnit)
        fxUnitStateObserverRegistry.registerObserver(btnPreventClipping, forFXUnit: audioGraphDelegate.replayGainUnit)
    }
    
    override func initControls() {
        
        super.initControls()

        modeMenuButton.selectItem(withTitle: replayGainUnit.mode.description)
        
        preAmpSlider.floatValue = replayGainUnit.preAmp
        
        if !replayGainUnit.isScanning {
            updateGainLabel()
        }
        
        lblPreAmp.stringValue = "\(String(format: "%.2f", replayGainUnit.preAmp)) dB"
        btnPreventClipping.onIf(replayGainUnit.preventClipping)
    }
    
    override func initSubscriptions() {
        
        super.initSubscriptions()
        
        messenger.subscribeAsync(to: .Player.trackTransitioned, handler: initControls)
        
        messenger.subscribeAsync(to: .Effects.ReplayGainUnit.scanInitiated, handler: scanInitiated)
        messenger.subscribeAsync(to: .Effects.ReplayGainUnit.scanCompleted, handler: updateGainLabel)
    }
    
    @IBAction func modeAction(_ sender: NSPopUpButton) {
        
        replayGainUnit.mode = .init(rawValue: sender.selectedTag()) ?? .defaultMode
        updateGainLabel()
        lblPreAmp.stringValue = "\(String(format: "%.2f", replayGainUnit.preAmp)) dB"
    }
    
    private func updateGainLabel() {
        
        if let appliedGain = replayGainUnit.appliedGain, let appliedGainType = replayGainUnit.appliedGainType {
            lblGain.stringValue = "\(String(format: "%.2f", appliedGain)) dB  (\(appliedGainType.description))"
            
        } else {
            lblGain.stringValue = "<None>"
        }
    }
    
    @IBAction func preAmpAction(_ sender: NSSlider) {
        
        replayGainUnit.preAmp = sender.floatValue
        lblPreAmp.stringValue = "\(String(format: "%.2f", replayGainUnit.preAmp)) dB"
    }
    
    @IBAction func preventClippingAction(_ sender: EffectsUnitToggle) {
        
        replayGainUnit.preventClipping = sender.isOn
        
        if !replayGainUnit.isScanning {
            updateGainLabel()
        }
    }
    
    private func scanInitiated() {
        lblGain.stringValue = "Analyzing \(replayGainUnit.mode == .preferAlbumGain ? "album" : "track") loudness ..."
    }
    
    override func fontSchemeChanged() {
        
        super.fontSchemeChanged()
        modeMenuButton.redraw()
    }
    
    override func colorSchemeChanged() {
        
        super.colorSchemeChanged()
        
        btnPreventClipping.redraw(forState: replayGainUnit.state)
        modeMenuButtonCell.tintColor = systemColorScheme.colorForEffectsUnitState(replayGainUnit.state)
    }
    
    override func activeControlColorChanged(_ newColor: NSColor) {
        
        super.activeControlColorChanged(newColor)
        
        if replayGainUnit.state == .active {
            
            btnPreventClipping.redraw(forState: .active)
            modeMenuButtonCell.tintColor = systemColorScheme.colorForEffectsUnitState(.active)
        }
    }
    
    override func inactiveControlColorChanged(_ newColor: NSColor) {
        
        super.inactiveControlColorChanged(newColor)
        
        if replayGainUnit.state == .bypassed {
            
            btnPreventClipping.redraw(forState: .bypassed)
            modeMenuButtonCell.tintColor = systemColorScheme.colorForEffectsUnitState(.bypassed)
        }
    }
    
    override func suppressedControlColorChanged(_ newColor: NSColor) {
        
        super.suppressedControlColorChanged(newColor)
        
        if replayGainUnit.state == .suppressed {
            
            btnPreventClipping.redraw(forState: .suppressed)
            modeMenuButtonCell.tintColor = systemColorScheme.colorForEffectsUnitState(.suppressed)
        }
    }
}

extension ReplayGainUnitViewController {
    
    override func menuNeedsUpdate(_ menu: NSMenu) {
        
        super.menuNeedsUpdate(menu)
        
        [dataSourceMenuItem_metadataOrAnalysis, dataSourceMenuItem_metadataOnly, dataSourceMenuItem_analysisOnly].forEach {
            $0?.off()
        }
        
        switch replayGainUnit.dataSource {
            
        case .metadataOrAnalysis:
            dataSourceMenuItem_metadataOrAnalysis.on()
            
        case .metadataOnly:
            dataSourceMenuItem_metadataOnly.on()
            
        case .analysisOnly:
            dataSourceMenuItem_analysisOnly.on()
        }
        
        switch replayGainUnit.maxPeakLevel {
            
        case .zero:
            
            maxPeakLevelMenuItem_zero.on()
            maxPeakLevelSelectorView.setCustomCheckboxState(.off)
            
        case .custom(_):
            
            maxPeakLevelMenuItem_zero.off()
            maxPeakLevelSelectorView.setCustomCheckboxState(.on)
        }
        
        maxPeakLevelSelectorView.prepareToAppear()
    }
    
    @IBAction func dataSourceAction(_ sender: NSMenuItem) {
        
        replayGainUnit.dataSource = .init(rawValue: sender.tag) ?? .metadataOrAnalysis
        updateGainLabel()
    }
    
    @IBAction func maxPeakLevelAction(_ sender: NSMenuItem) {
        
        replayGainUnit.maxPeakLevel = .zero
        maxPeakLevelSelectorView.setCustomCheckboxState(.off)
    }
    
    @IBAction func customMaxPeakLevelCheckboxAction(_ sender: CheckBox) {
        
        maxPeakLevelSelectorView.setCustomCheckboxState(sender.state)
        maxPeakLevelMenuItem_zero.onIf(maxPeakLevelSelectorView.btnCustomDecibel.isOff)
    }
}
