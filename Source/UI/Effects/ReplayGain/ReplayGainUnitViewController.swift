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
        self.presetsWrapper = PresetsWrapper<EQPreset, EQPresets>(audioGraph.eqUnit.presets)
        
        if let popupMenuCell = modeMenuButton.cell as? EffectsUnitPopupMenuCell {
            fxUnitStateObserverRegistry.registerObserver(popupMenuCell, forFXUnit: graph.replayGainUnit)
        }
    }
    
    override func oneTimeSetup() {
        
        super.oneTimeSetup()
//        eqUnitView.initialize(eqStateFunction: unitStateFunction,
//                              sliderAction: #selector(self.eqSliderAction(_:)), sliderActionTarget: self)
        initializeView()
    }
    
    private func initializeView() {
        
        modeMenuButton.selectItem(withTitle: replayGainUnit.mode.description)
        preAmpSlider.floatValue = replayGainUnit.preAmp
        
        lblAppliedGain.stringValue = "\(String(format: "%.2f", replayGainUnit.appliedGain)) dB  (\(replayGainUnit.mode.description))"
        lblPreAmp.stringValue = "\(String(format: "%.2f", replayGainUnit.preAmp)) dB"
        lblTotalGain.stringValue = "\(String(format: "%.2f", replayGainUnit.effectiveGain)) dB"
        
        fxUnitStateObserverRegistry.registerObserver(preAmpSlider!, forFXUnit: effectsUnit)
    }
    
    @IBAction func modeAction(_ sender: NSPopUpButton) {
        
        guard let modeDescription = sender.titleOfSelectedItem else {return}
        
        replayGainUnit.mode = .fromDescription(modeDescription) ?? .defaultMode
        
        lblAppliedGain.stringValue = "\(String(format: "%.2f", replayGainUnit.appliedGain)) dB  (\(replayGainUnit.mode.description))"
        lblPreAmp.stringValue = "\(String(format: "%.2f", replayGainUnit.preAmp)) dB"
        lblTotalGain.stringValue = "\(String(format: "%.2f", replayGainUnit.effectiveGain)) dB"
    }
    
    @IBAction func preAmpAction(_ sender: NSSlider) {
        
        replayGainUnit.preAmp = sender.floatValue
        print(replayGainUnit.preAmp)
        
        lblPreAmp.stringValue = "\(String(format: "%.2f", replayGainUnit.preAmp)) dB"
        lblTotalGain.stringValue = "\(String(format: "%.2f", replayGainUnit.effectiveGain)) dB"
    }
}
