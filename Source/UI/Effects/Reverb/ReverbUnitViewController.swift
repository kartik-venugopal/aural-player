//
//  ReverbUnitViewController.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    View controller for the Reverb effects unit
 */
class ReverbUnitViewController: EffectsUnitViewController {
    
    override var nibName: String? {"ReverbUnit"}
    
    // ------------------------------------------------------------------------
    
    // MARK: UI fields
    
    @IBOutlet weak var reverbUnitView: ReverbUnitView!
    
    // ------------------------------------------------------------------------
    
    // MARK: Services, utilities, helpers, and properties
    
    var reverbUnit: ReverbUnitDelegateProtocol = objectGraph.audioGraphDelegate.reverbUnit
    
    // ------------------------------------------------------------------------
    
    // MARK: UI initialization / life-cycle
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        effectsUnit = graph.reverbUnit
        presetsWrapper = PresetsWrapper<ReverbPreset, ReverbPresets>(reverbUnit.presets)
    }
    
    override func oneTimeSetup() {
        
        super.oneTimeSetup()
        reverbUnitView.initialize(stateFunction: unitStateFunction)
    }
    
    override func initControls() {
        
        super.initControls()
        reverbUnitView.setState(space: reverbUnit.space.description,
                                amount: reverbUnit.amount, amountString: reverbUnit.formattedAmount)
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Actions

    // Updates the Reverb preset
    @IBAction func reverbSpaceAction(_ sender: AnyObject) {
        reverbUnit.space = ReverbSpace.fromDescription(reverbUnitView.spaceString)
    }

    // Updates the Reverb amount parameter
    @IBAction func reverbAmountAction(_ sender: AnyObject) {
        
        reverbUnit.amount = reverbUnitView.amount
        reverbUnitView.setAmountString(reverbUnit.formattedAmount)
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Message handling
    
    override func initSubscriptions() {
        
        super.initSubscriptions()
        
        messenger.subscribe(to: .changeTextButtonMenuColor, handler: changeTextButtonMenuColor(_:))
        messenger.subscribe(to: .changeButtonMenuTextColor, handler: changeButtonMenuTextColor(_:))
    }
    
    override func stateChanged() {
        
        super.stateChanged()
        reverbUnitView.stateChanged()
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Theming
    
    override func applyFontScheme(_ fontScheme: FontScheme) {
        
        super.applyFontScheme(fontScheme)
        reverbUnitView.applyFontScheme(fontScheme)
    }
    
    override func applyColorScheme(_ scheme: ColorScheme) {
        
        super.applyColorScheme(scheme)
        
        changeSliderColors()
        reverbUnitView.redrawMenu()
    }
    
    override func changeSliderColors() {
        reverbUnitView.redrawSliders()
    }
    
    override func changeActiveUnitStateColor(_ color: NSColor) {
        
        super.changeActiveUnitStateColor(color)
        
        if reverbUnit.isActive {
            reverbUnitView.redrawSliders()
        }
    }
    
    override func changeBypassedUnitStateColor(_ color: NSColor) {
        
        super.changeBypassedUnitStateColor(color)
        
        if reverbUnit.state == .bypassed {
            reverbUnitView.redrawSliders()
        }
    }
    
    override func changeSuppressedUnitStateColor(_ color: NSColor) {
        
        super.changeSuppressedUnitStateColor(color)
        
        if reverbUnit.state == .suppressed {
            reverbUnitView.redrawSliders()
        }
    }
    
    func changeTextButtonMenuColor(_ color: NSColor) {
        reverbUnitView.redrawMenu()
    }
    
    func changeButtonMenuTextColor(_ color: NSColor) {
        reverbUnitView.redrawMenu()
    }
}
