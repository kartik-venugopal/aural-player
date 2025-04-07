//
//  EQUnitView.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class EQUnitView: NSView, Destroyable {
    
    // ------------------------------------------------------------------------
    
    // MARK: UI fields
    
    @IBOutlet weak var globalGainSlider: EQSlider!
    
    var bandSliders: [EQSlider] = []
    var allSliders: [EQSlider] = []
    
    var stateFunction: EffectsUnitStateFunction!
    var sliderAction: Selector?
    weak var sliderActionTarget: AnyObject?
    
    // ------------------------------------------------------------------------
    
    // MARK: Properties
    
    var globalGain: Float {
        globalGainSlider.floatValue
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: View initialization
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        allSliders = subviews.compactMap({$0 as? EQSlider})
        bandSliders = allSliders.filter {$0.tag >= 0}
        
        bandSliders.forEach {
            
            $0.action = sliderAction
            $0.target = sliderActionTarget
        }
    }
    
    func initialize(eqStateFunction: @escaping EffectsUnitStateFunction,
                    sliderAction: Selector?, sliderActionTarget: AnyObject?) {

        self.stateFunction = eqStateFunction
        self.sliderAction = sliderAction
        self.sliderActionTarget = sliderActionTarget
        
        bandSliders.forEach {
            
            $0.action = sliderAction
            $0.target = sliderActionTarget
        }
    }
    
    func destroy() {
        
        sliderAction = nil
        sliderActionTarget = nil
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: View update
    
    func setState(bands: [Float], globalGain: Float) {
        bandsUpdated(bands, globalGain: globalGain)
    }

    func bandsUpdated(_ bands: [Float], globalGain: Float) {
        
        // Slider tag = index. Default gain value, if bands array doesn't contain gain for index, is 0
        bandSliders.forEach {
            
            $0.floatValue = $0.tag < bands.count ? bands[$0.tag] : AudioGraphDefaults.eqBandGain
            $0.toolTip = "\($0.frequencyString!): \(String(format: "%.1f dB", $0.floatValue))"
        }
        
        globalGainSlider.floatValue = globalGain
        globalGainSlider.toolTip = "\(globalGainSlider.frequencyString!): \(String(format: "%.1f dB", globalGainSlider.floatValue))"
    }
    
    func applyPreset(_ preset: EQPreset) {
        bandsUpdated(preset.bands, globalGain: preset.globalGain)
    }
}
