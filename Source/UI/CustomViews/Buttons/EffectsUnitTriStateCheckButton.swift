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
        reTint()
    }
    
    func reTint() {
        
        switch unitState {

        case .bypassed:

            image = image?.tintedWithColor(bypassedStateColor)
            alternateImage = alternateImage?.tintedWithColor(bypassedStateColor)

        case .active:

            image = image?.tintedWithColor(activeStateColor)
            alternateImage = alternateImage?.tintedWithColor(activeStateColor)

        case .suppressed:

            image = image?.tintedWithColor(suppressedStateColor)
            alternateImage = alternateImage?.tintedWithColor(suppressedStateColor)
        }
    }
}

class EffectsUnitTriStatePreviewCheckButton: EffectsUnitTriStateCheckButton {
    
    override var activeStateColor: NSColor {Colors.Effects.defaultActiveUnitColor}
    
    override var bypassedStateColor: NSColor {Colors.Effects.defaultBypassedUnitColor}
    
    override var suppressedStateColor: NSColor {Colors.Effects.defaultSuppressedUnitColor}
    
    override func awakeFromNib() {
        stateChanged()
    }
}
