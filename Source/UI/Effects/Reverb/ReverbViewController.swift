//
//  ReverbViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    View controller for the Reverb effects unit
 */
class ReverbViewController: EffectsUnitViewController {
    
    @IBOutlet weak var reverbView: ReverbView!
    
    override var nibName: String? {"Reverb"}
    
    var reverbUnit: ReverbUnitDelegateProtocol = objectGraph.audioGraphDelegate.reverbUnit
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        effectsUnit = graph.reverbUnit
        presetsWrapper = PresetsWrapper<ReverbPreset, ReverbPresets>(reverbUnit.presets)
    }
    
    override func oneTimeSetup() {
        
        super.oneTimeSetup()
        reverbView.initialize(self.unitStateFunction)
    }
    
    override func initSubscriptions() {
        
        super.initSubscriptions()
        
        messenger.subscribe(to: .changeTextButtonMenuColor, handler: changeTextButtonMenuColor(_:))
        messenger.subscribe(to: .changeButtonMenuTextColor, handler: changeButtonMenuTextColor(_:))
    }
    
    override func initControls() {
        
        super.initControls()
        reverbView.setState(reverbUnit.space.description, reverbUnit.amount, reverbUnit.formattedAmount)
    }

    override func stateChanged() {
        
        super.stateChanged()
        reverbView.stateChanged()
    }

    // Updates the Reverb preset
    @IBAction func reverbSpaceAction(_ sender: AnyObject) {
        reverbUnit.space = ReverbSpaces.fromDescription(reverbView.spaceString)
    }

    // Updates the Reverb amount parameter
    @IBAction func reverbAmountAction(_ sender: AnyObject) {
        
        reverbUnit.amount = reverbView.amount
        reverbView.setAmount(reverbUnit.amount, reverbUnit.formattedAmount)
    }
    
    override func applyFontScheme(_ fontScheme: FontScheme) {
        
        super.applyFontScheme(fontScheme)
        reverbView.applyFontScheme(fontScheme)
    }
    
    override func applyColorScheme(_ scheme: ColorScheme) {
        
        super.applyColorScheme(scheme)
        
        changeSliderColors()
        reverbView.redrawMenu()
    }
    
    override func changeSliderColors() {
        reverbView.redrawSliders()
    }
    
    override func changeActiveUnitStateColor(_ color: NSColor) {
        
        super.changeActiveUnitStateColor(color)
        
        if reverbUnit.isActive {
            reverbView.redrawSliders()
        }
    }
    
    override func changeBypassedUnitStateColor(_ color: NSColor) {
        
        super.changeBypassedUnitStateColor(color)
        
        if reverbUnit.state == .bypassed {
            reverbView.redrawSliders()
        }
    }
    
    override func changeSuppressedUnitStateColor(_ color: NSColor) {
        
        super.changeSuppressedUnitStateColor(color)
        
        if reverbUnit.state == .suppressed {
            reverbView.redrawSliders()
        }
    }
    
    func changeTextButtonMenuColor(_ color: NSColor) {
        reverbView.redrawMenu()
    }
    
    func changeButtonMenuTextColor(_ color: NSColor) {
        reverbView.redrawMenu()
    }
}
