//
//  ReverbUnitViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    View controller for the Reverb effects unit
 */
class ReverbUnitViewController: EffectsUnitViewController {
    
    override var nibName: NSNib.Name? {"ReverbUnit"}
    
    // ------------------------------------------------------------------------
    
    // MARK: UI fields
    
    @IBOutlet weak var reverbUnitView: ReverbUnitView!
    
    // ------------------------------------------------------------------------
    
    // MARK: Services, utilities, helpers, and properties
    
    var reverbUnit: ReverbUnitDelegateProtocol = audioGraphDelegate.reverbUnit
    
    // ------------------------------------------------------------------------
    
    // MARK: UI initialization / life-cycle
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        effectsUnit = audioGraphDelegate.reverbUnit
        presetsWrapper = PresetsWrapper<ReverbPreset, ReverbPresets>(reverbUnit.presets)
    }
    
    override func initControls() {
        
        super.initControls()
        
        reverbUnitView.setState(space: reverbUnit.space.description,
                                amount: reverbUnit.amount,
                                amountString: reverbUnit.formattedAmount)
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
        reverbUnitView.setAmount(reverbUnit.amount, amountString: reverbUnit.formattedAmount)
    }
    
    override func fontSchemeChanged() {
        
        super.fontSchemeChanged()
        reverbUnitView.redrawPopupMenu()
    }
    
    override func colorSchemeChanged() {
        
        super.colorSchemeChanged()
        reverbUnitView.updatePopupMenuColor(systemColorScheme.colorForEffectsUnitState(reverbUnit.state))
    }
    
    override func activeControlColorChanged(_ newColor: NSColor) {
        
        super.activeControlColorChanged(newColor)
        
        if reverbUnit.state == .active {
            reverbUnitView.updatePopupMenuColor(systemColorScheme.activeControlColor)
        }
    }
    
    override func inactiveControlColorChanged(_ newColor: NSColor) {
        
        super.inactiveControlColorChanged(newColor)
        
        if reverbUnit.state == .bypassed {
            reverbUnitView.updatePopupMenuColor(systemColorScheme.inactiveControlColor)
        }
    }
    
    override func suppressedControlColorChanged(_ newColor: NSColor) {
        
        super.suppressedControlColorChanged(newColor)
        
        if reverbUnit.state == .suppressed {
            reverbUnitView.updatePopupMenuColor(systemColorScheme.suppressedControlColor)
        }
    }
}

extension ReverbUnitViewController: ThemeInitialization {
    
    func initTheme() {
        
        super.fontSchemeChanged()
        super.colorSchemeChanged()
        
        reverbUnitView.updatePopupMenuColor(systemColorScheme.colorForEffectsUnitState(reverbUnit.state))
    }
}
