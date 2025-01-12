//
//  EffectsUnitTabButton.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

@IBDesignable
class EffectsUnitTabButton: OnOffImageButton, FXUnitStateObserver {
    
    var stateFunction: EffectsUnitStateFunction?
    
    @IBInspectable var mixedStateTooltip: String?
    
    override func off() {
        
        toolTip = offStateTooltip
        state = .off
    }
    
    override func on() {
        
        toolTip = onStateTooltip
        state = .on
    }
    
    func mixed() {
        toolTip = mixedStateTooltip
    }
    
    func unitStateChanged(to newState: EffectsUnitState) {
        
        switch newState {
            
        case .bypassed: off()
            
        case .active: on()
            
        case .suppressed: mixed()
            
        }
        
        redraw()
    }
    
    var isSelected: Bool = false {
        
        didSet {
            redraw()
        }
    }
    
    func select() {
        isSelected = true
    }
    
    func unSelect() {
        isSelected = false
    }
}
