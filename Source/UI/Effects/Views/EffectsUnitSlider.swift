//
//  EffectsUnitSlider.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

protocol EffectsUnitSliderProtocol {
    
    var effectsUnit: EffectsUnitDelegateProtocol! {get set}
}

protocol EffectsUnitSliderCellProtocol {
    
    var effectsUnit: EffectsUnitDelegateProtocol! {get set}
}

extension NSSlider {

    public override func setNeedsDisplay(_ invalidRect: NSRect) {
        super.setNeedsDisplay(bounds)
    }
}

class EffectsUnitSlider: NSSlider, FXUnitStateObserver {
    
    override var isFlipped: Bool {false}
}

@IBDesignable
class EQSlider: EffectsUnitSlider {
    
    /// Used as prefixes (eg. "25Hz band") in tool tips that display the current gain value for the EQ sliders..
    @IBInspectable var frequencyString: String!
}
