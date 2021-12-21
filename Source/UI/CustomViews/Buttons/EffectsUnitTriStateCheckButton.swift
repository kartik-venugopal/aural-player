//
//  EffectsUnitTriStateCheckButton.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

@IBDesignable
class EffectsUnitTriStateCheckButton: NSButton {
    
    var stateFunction: (() -> EffectsUnitState)? {
        didSet {reTint()}
    }

    var unitState: EffectsUnitState {
        return stateFunction?() ?? .bypassed
    }
    
    var activeStateColor: NSColor {Colors.Effects.activeUnitStateColor}
    
    var bypassedStateColor: NSColor {Colors.Effects.bypassedUnitStateColor}
    
    var suppressedStateColor: NSColor {Colors.Effects.suppressedUnitStateColor}
        
    func stateChanged() {
     
        switch unitState {

        case .bypassed:

            alternateImage = alternateImage?.tintedWithColor(bypassedStateColor)

        case .active:

            alternateImage = alternateImage?.tintedWithColor(activeStateColor)

        case .suppressed:

            alternateImage = alternateImage?.tintedWithColor(suppressedStateColor)
        }
    }
    
    func reTint() {
        
        image = image?.tintedWithColor(bypassedStateColor)

        switch unitState {

        case .bypassed:
            
            alternateImage = alternateImage?.tintedWithColor(bypassedStateColor)

        case .active:
            
            alternateImage = alternateImage?.tintedWithColor(activeStateColor)

        case .suppressed:

            alternateImage = alternateImage?.tintedWithColor(suppressedStateColor)
        }
    }
}

