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
        reverbSpaceMenu.titleOfSelectedItem!
    }
    
    var amount: Float {
        reverbAmountSlider.floatValue
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
        
        setSpace(space)
        setAmount(amount, amountString: amountString)
    }
    
    func setUnitState(_ state: EffectsUnitState) {
        reverbAmountSlider.setUnitState(state)
    }
    
    func setSpace(_ space: String) {
        reverbSpaceMenu.selectItem(withTitle: space)
    }
    
    func setAmount(_ amount: Float, amountString: String) {
        
        reverbAmountSlider.floatValue = amount
        lblReverbAmountValue.stringValue = amountString
    }
    
    func stateChanged() {
        reverbAmountSlider.updateState()
    }
    
    func applyPreset(_ preset: ReverbPreset) {
        
        setUnitState(preset.state)
        setSpace(preset.space.description)
        setAmount(preset.amount, amountString: ValueFormatter.formatReverbAmount(preset.amount))
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
