//
//  EffectsUnitTabButton.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

@IBDesignable
class EffectsUnitTabButton: OnOffImageButton {
    
    var stateFunction: EffectsUnitStateFunction?
    
    @IBInspectable var mixedStateTooltip: String?
    
    var mixedStateTintFunction: () -> NSColor = {Colors.Effects.suppressedUnitStateColor} {
        didSet {reTint()}
    }
    
    override func awakeFromNib() {
        
        // Override the tint functions from OnOffImageButton
        offStateTintFunction = {Colors.Effects.bypassedUnitStateColor}
        onStateTintFunction = {Colors.Effects.activeUnitStateColor}
    }
    
    override func off() {
        
        self.image = self.image?.filledWithColor(offStateTintFunction())
        self.toolTip = offStateTooltip
        _isOn = false
        
        if let cell = self.cell as? EffectsUnitTabButtonCell {
            
            cell.unitState = .bypassed
            redraw()
        }
    }
    
    override func on() {
        
        self.image = self.image?.filledWithColor(onStateTintFunction())
        self.toolTip = onStateTooltip
        _isOn = true
        
        if let cell = self.cell as? EffectsUnitTabButtonCell {
            
            cell.unitState = .active
            redraw()
        }
    }
    
    func mixed() {
        
        self.image = self.image?.filledWithColor(mixedStateTintFunction())
        self.toolTip = mixedStateTooltip
        
        if let cell = self.cell as? EffectsUnitTabButtonCell {
            
            cell.unitState = .suppressed
            redraw()
        }
    }
    
    override func reTint() {
        
        let tintColor: NSColor
        
        switch unitState {
            
        case .bypassed: tintColor = offStateTintFunction()
            
        case .active: tintColor = onStateTintFunction()
            
        case .suppressed: tintColor = mixedStateTintFunction()
            
        }
        
        self.image = self.image?.filledWithColor(tintColor)
        
        // Need to redraw because we are using a custom button cell which needs to render the updated image itself
        redraw()
    }
    
    func updateState() {
        
        let newState = stateFunction!()
        
        switch newState {
            
        case .bypassed: off()
            
        case .active: on()
            
        case .suppressed: mixed()
            
        }
    }
    
    var unitState: EffectsUnitState {
        stateFunction?() ?? .bypassed
    }
    
    func select() {
        self.state = .on
    }
    
    func unSelect() {
        self.state = .off
    }
}
