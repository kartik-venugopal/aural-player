//
//  ReverbUnitView.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class ReverbUnitView: NSView {
    
    // ------------------------------------------------------------------------
    
    // MARK: UI fields
    
    @IBOutlet weak var reverbSpaceMenu: NSPopUpButton!
    @IBOutlet weak var reverbAmountSlider: EffectsUnitSlider!
    @IBOutlet weak var lblReverbAmountValue: NSTextField!
    
    // ------------------------------------------------------------------------
    
    // MARK: Properties
    
    var spaceString: String {
        
        get {reverbSpaceMenu.titleOfSelectedItem!}
        set {reverbSpaceMenu.selectItem(withTitle: newValue)}
    }
    
    var amount: Float {
        
        get {reverbAmountSlider.floatValue}
        set {reverbAmountSlider.floatValue = newValue}
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: View initialization
    
    func initialize(stateFunction: @escaping EffectsUnitStateFunction) {
        
        reverbAmountSlider.stateFunction = stateFunction
        reverbAmountSlider.updateState()
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: View update
    
    func setState(space: String, amount: Float, amountString: String) {
        
        self.spaceString = space
        self.amount = amount
        setAmountString(amountString)
    }
    
    func setUnitState(_ state: EffectsUnitState) {
        reverbAmountSlider.setUnitState(state)
    }
    
    func setAmountString(_ amountString: String) {
        lblReverbAmountValue.stringValue = amountString
    }
    
    func stateChanged() {
        reverbAmountSlider.updateState()
    }
    
    func applyPreset(_ preset: ReverbPreset) {
        
        setUnitState(preset.state)
        self.spaceString = preset.space.description
        self.amount = preset.amount
        setAmountString(ValueFormatter.formatReverbAmount(preset.amount))
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Theming
    
    func applyFontScheme(_ fontScheme: FontScheme) {
        
        reverbSpaceMenu.font = fontScheme.effects.unitFunctionFont
        reverbSpaceMenu.redraw()
    }
    
    func redrawSliders() {
        reverbAmountSlider.redraw()
    }
    
    func redrawMenu() {
        reverbSpaceMenu.redraw()
    }
}
