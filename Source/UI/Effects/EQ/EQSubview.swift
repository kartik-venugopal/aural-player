//
//  EQSubview.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class EQSubview: NSView {
    
    @IBOutlet weak var globalGainSlider: EffectsUnitSlider!
    
    var bandSliders: [EffectsUnitSlider] = []
    var allSliders: [EffectsUnitSlider] = []
    
    override func awakeFromNib() {
        
        for subView in self.subviews {
            
            if let slider = subView as? EffectsUnitSlider {
                
                if slider.tag >= 0 {bandSliders.append(slider)}
                allSliders.append(slider)
            }
        }
    }
    
    func initialize(_ stateFunction: @escaping EffectsUnitStateFunction, _ sliderAction: Selector?, _ sliderActionTarget: AnyObject?) {
        
        allSliders.forEach {$0.stateFunction = stateFunction}
        
        bandSliders.forEach({
            $0.action = sliderAction
            $0.target = sliderActionTarget
        })
    }
    
    func stateChanged() {
        allSliders.forEach {$0.updateState()}
    }
    
    func changeSliderColor() {
        allSliders.forEach {$0.redraw()}
    }
    
    func changeActiveUnitStateColor(_ color: NSColor) {
        allSliders.forEach {$0.redraw()}
    }
    
    func changeBypassedUnitStateColor(_ color: NSColor) {
        allSliders.forEach {$0.redraw()}
    }
    
    func changeSuppressedUnitStateColor(_ color: NSColor) {
        allSliders.forEach {$0.redraw()}
    }
    
    func setState(_ state: EffectsUnitState) {
        allSliders.forEach {$0.setUnitState(state)}
    }
    
    func updateBands(_ bands: [Float], _ globalGain: Float) {
        
        // TODO: Simplify this (see if it can be done in the Delegate layer).
        
        // If number of bands doesn't match, need to perform a mapping
        if bands.count != bandSliders.count {
            
            let mappedBands = bands.count == 10 ?
                ParametricEQ.map10BandsTo15Bands(bands) :
                ParametricEQ.map15BandsTo10Bands(bands)
            
            self.updateBands(mappedBands, globalGain)
            return
        }
        
        // Slider tag = index. Default gain value, if bands array doesn't contain gain for index, is 0
        bandSliders.forEach {
            $0.floatValue = $0.tag < bands.count ? bands[$0.tag] : AudioGraphDefaults.eqBandGain
        }
        
        globalGainSlider.floatValue = globalGain
    }
}
