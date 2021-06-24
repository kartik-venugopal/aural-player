//
//  ReverbView.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class ReverbView: NSView {
    
    @IBOutlet weak var reverbSpaceMenu: NSPopUpButton!
    @IBOutlet weak var reverbAmountSlider: FXUnitSlider!
    @IBOutlet weak var lblReverbAmountValue: NSTextField!
    
    private let fontSchemesManager: FontSchemesManager = ObjectGraph.fontSchemesManager
    
    var spaceString: String {
        return reverbSpaceMenu.titleOfSelectedItem!
    }
    
    var amount: Float {
        return reverbAmountSlider.floatValue
    }
    
    func initialize(_ stateFunction: (() -> FXUnitState)?) {
        reverbAmountSlider.stateFunction = stateFunction
        reverbAmountSlider.updateState()
    }
    
    func setState(_ space: String , _ amount: Float, _ amountString: String) {
        setSpace(space)
        setAmount(amount, amountString)
    }
    
    func setUnitState(_ state: FXUnitState) {
        reverbAmountSlider.setUnitState(state)
    }
    
    func setSpace(_ space: String) {
        reverbSpaceMenu.selectItem(withTitle: space)
    }
    
    func setAmount(_ amount: Float, _ amountString: String) {
        reverbAmountSlider.floatValue = amount
        lblReverbAmountValue.stringValue = amountString
    }
    
    func stateChanged() {
        reverbAmountSlider.updateState()
    }
    
    func applyPreset(_ preset: ReverbPreset) {
        
        setUnitState(preset.state)
        setSpace(preset.space.description)
        setAmount(preset.amount, ValueFormatter.formatReverbAmount(preset.amount))
    }
    
    func applyFontScheme(_ fontScheme: FontScheme) {
        
        reverbSpaceMenu.font = fontSchemesManager.systemScheme.effects.unitFunctionFont
        reverbSpaceMenu.redraw()
    }
    
    func redrawSliders() {
        reverbAmountSlider.redraw()
    }
    
    func redrawMenu() {
        reverbSpaceMenu.redraw()
    }
}
