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
    @IBOutlet weak var sourceMenuButton: NSPopUpButton!
    
    @IBOutlet weak var lblAppliedGain: NSTextField!
    
    @IBOutlet weak var preAmpSlider: EffectsUnitSlider!
    @IBOutlet weak var lblPreAmp: NSTextField!
    
    @IBOutlet weak var lblTotalGain: NSTextField!
    
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
        
        if let popupMenuCell = sourceMenuButton.cell as? EffectsUnitPopupMenuCell {
            fxUnitStateObserverRegistry.registerObserver(popupMenuCell, forFXUnit: graph.replayGainUnit)
        }
    }
    
    override func initControls() {
        
        super.initControls()

        sourceMenuButton.selectItem(withTitle: "Metadata or analysis")
        modeMenuButton.selectItem(withTitle: replayGainUnit.mode.description)
        
        preAmpSlider.floatValue = replayGainUnit.preAmp
        
        if replayGainUnit.hasAppliedGain {
            lblAppliedGain.stringValue = "\(String(format: "%.2f", replayGainUnit.appliedGain)) dB  (\(replayGainUnit.mode.description))"
            
        } else {
            lblAppliedGain.stringValue = "<None>"
        }
        
        lblPreAmp.stringValue = "\(String(format: "%.2f", replayGainUnit.preAmp)) dB"
        lblTotalGain.stringValue = "\(String(format: "%.2f", replayGainUnit.effectiveGain)) dB"
    }
    
    override func initSubscriptions() {
        
        super.initSubscriptions()
        messenger.subscribeAsync(to: .Player.trackTransitioned, handler: initControls)
    }
    
    @IBAction func modeAction(_ sender: NSPopUpButton) {
        
        guard let modeDescription = sender.titleOfSelectedItem else {return}
        
        replayGainUnit.mode = .init(rawValue: sender.tag) ?? .defaultMode
        
        if replayGainUnit.hasAppliedGain {
            lblAppliedGain.stringValue = "\(String(format: "%.2f", replayGainUnit.appliedGain)) dB  (\(replayGainUnit.mode.description))"
            
        } else {
            lblAppliedGain.stringValue = "<None>"
        }
        
        lblPreAmp.stringValue = "\(String(format: "%.2f", replayGainUnit.preAmp)) dB"
        lblTotalGain.stringValue = "\(String(format: "%.2f", replayGainUnit.effectiveGain)) dB"
    }
    
    @IBAction func preAmpAction(_ sender: NSSlider) {
        
        replayGainUnit.preAmp = sender.floatValue
        
        lblPreAmp.stringValue = "\(String(format: "%.2f", replayGainUnit.preAmp)) dB"
        lblTotalGain.stringValue = "\(String(format: "%.2f", replayGainUnit.effectiveGain)) dB"
    }
}
