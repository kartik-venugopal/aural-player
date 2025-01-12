//
//  EffectsUnitSliderCell.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

// Cell for all ticked effects sliders
class EffectsUnitSliderCell: HorizontalSliderCell {
    
    override var barRadius: CGFloat {1.5}
    
    override var knobWidth: CGFloat {12}
    override var knobRadius: CGFloat {1}
    override var knobHeightOutsideBar: CGFloat {3.5}
    
    lazy var observingSlider: EffectsUnitSlider = controlView as! EffectsUnitSlider
    
    override var controlStateColor: NSColor {
        systemColorScheme.colorForEffectsUnitState(fxUnitStateObserverRegistry.currentState(forObserver: observingSlider))
    }
}
