//
//  ReplayGainUnitViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
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
    
    @IBOutlet weak var lblGain: NSTextField!
    
    @IBOutlet weak var preAmpSlider: EffectsUnitSlider!
    @IBOutlet weak var lblPreAmp: NSTextField!
    
    @IBOutlet weak var btnPreventClipping: EffectsUnitToggle!
    
    // ------------------------------------------------------------------------
    
    // MARK: Services, utilities, helpers, and properties
    
    private var replayGainUnit: ReplayGainUnitDelegateProtocol = audioGraphDelegate.replayGainUnit
    
    // ------------------------------------------------------------------------
    
    // MARK: UI initialization / life-cycle
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        self.effectsUnit = graph.replayGainUnit
        self.presetsWrapper = PresetsWrapper<ReplayGainPreset, ReplayGainPresets>(audioGraph.replayGainUnit.presets)
        
        if let popupMenuCell = modeMenuButton.cell as? EffectsUnitPopupMenuCell {
            fxUnitStateObserverRegistry.registerObserver(popupMenuCell, forFXUnit: graph.replayGainUnit)
        }
        
        fxUnitStateObserverRegistry.registerObserver(btnPreventClipping, forFXUnit: audioGraphDelegate.replayGainUnit)
    }
    
    override func initControls() {
        
        super.initControls()

        modeMenuButton.selectItem(withTitle: replayGainUnit.mode.description)
        
        preAmpSlider.floatValue = replayGainUnit.preAmp
        
        if !replayGainUnit.isScanning {
            
            if replayGainUnit.hasAppliedGain {
                lblGain.stringValue = "\(String(format: "%.2f", replayGainUnit.appliedGain)) dB  (\(replayGainUnit.mode.description))"
                
            } else {
                lblGain.stringValue = "<None>"
            }
        }
        
        lblPreAmp.stringValue = "\(String(format: "%.2f", replayGainUnit.preAmp)) dB"
        btnPreventClipping.onIf(replayGainUnit.preventClipping)
    }
    
    override func initSubscriptions() {
        
        super.initSubscriptions()
        
        messenger.subscribeAsync(to: .Player.trackTransitioned, handler: initControls)
        
        messenger.subscribeAsync(to: .Effects.ReplayGainUnit.scanInitiated, handler: scanInitiated)
        messenger.subscribeAsync(to: .Effects.ReplayGainUnit.scanCompleted, handler: scanCompleted)
    }
    
    @IBAction func modeAction(_ sender: NSPopUpButton) {
        
        replayGainUnit.mode = .init(rawValue: sender.selectedTag()) ?? .defaultMode
        
        if replayGainUnit.hasAppliedGain {
            lblGain.stringValue = "\(String(format: "%.2f", replayGainUnit.appliedGain)) dB  (\(replayGainUnit.mode.description))"
            
        } else {
            lblGain.stringValue = "<None>"
        }
        
        lblPreAmp.stringValue = "\(String(format: "%.2f", replayGainUnit.preAmp)) dB"
    }
    
    @IBAction func preAmpAction(_ sender: NSSlider) {
        
        replayGainUnit.preAmp = sender.floatValue
        lblPreAmp.stringValue = "\(String(format: "%.2f", replayGainUnit.preAmp)) dB"
    }
    
    @IBAction func preventClippingAction(_ sender: EffectsUnitToggle) {
        
        replayGainUnit.preventClipping = sender.isOn
        
        if !replayGainUnit.isScanning {
            
            if replayGainUnit.hasAppliedGain {
                lblGain.stringValue = "\(String(format: "%.2f", replayGainUnit.appliedGain)) dB  (\(replayGainUnit.mode.description))"
                
            } else {
                lblGain.stringValue = "<None>"
            }
        }
    }
    
    private func scanInitiated() {
        lblGain.stringValue = "Analyzing file loudness ..."
    }
    
    private func scanCompleted() {
        lblGain.stringValue = "\(String(format: "%.2f", replayGainUnit.appliedGain)) dB  (\(replayGainUnit.mode.description))"
    }
    
    override func colorSchemeChanged() {
        
        super.colorSchemeChanged()
        btnPreventClipping.redraw(forState: replayGainUnit.state)
    }
    
    override func activeControlColorChanged(_ newColor: NSColor) {
        
        super.activeControlColorChanged(newColor)
        
        if replayGainUnit.state == .active {
            btnPreventClipping.redraw(forState: .active)
        }
    }
    
    override func inactiveControlColorChanged(_ newColor: NSColor) {
        
        super.inactiveControlColorChanged(newColor)
        
        if replayGainUnit.state == .bypassed {
            btnPreventClipping.redraw(forState: .bypassed)
        }
    }
    
    override func suppressedControlColorChanged(_ newColor: NSColor) {
        
        super.suppressedControlColorChanged(newColor)
        
        if replayGainUnit.state == .suppressed {
            btnPreventClipping.redraw(forState: .suppressed)
        }
    }
}
