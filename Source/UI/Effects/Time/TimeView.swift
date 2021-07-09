//
//  TimeView.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class TimeView: NSView {
    
    @IBOutlet weak var timeSlider: EffectsUnitSlider!
    @IBOutlet weak var timeOverlapSlider: EffectsUnitSlider!
    
    @IBOutlet weak var btnShiftPitch: NSButton!
    
    @IBOutlet weak var lblTimeStretchRateValue: NSTextField!
    @IBOutlet weak var lblPitchShiftValue: NSTextField!
    @IBOutlet weak var lblTimeOverlapValue: NSTextField!
    
    private var sliders: [EffectsUnitSlider] = []
    
    var rate: Float {
        return timeSlider.floatValue
    }
    
    var overlap: Float {
        return timeOverlapSlider.floatValue
    }
    
    var shiftPitch: Bool {
        return btnShiftPitch.isOn
    }
    
    override func awakeFromNib() {
        sliders = [timeSlider, timeOverlapSlider]
    }
    
    func initialize(_ stateFunction: (() -> EffectsUnitState)?) {
        
        sliders.forEach({
            $0.stateFunction = stateFunction
            $0.updateState()
        })
    }
    
    func setUnitState(_ state: EffectsUnitState) {
        sliders.forEach({$0.setUnitState(state)})
    }
    
    func stateChanged() {
        sliders.forEach({$0.updateState()})
    }
    
    func setState(_ rate: Float, _ rateString: String, _ overlap: Float, _ overlapString: String, _ shiftPitch: Bool, _ shiftPitchString: String) {
        
        btnShiftPitch.onIf(shiftPitch)
        updatePitchShift(shiftPitchString)
        
        timeSlider.floatValue = rate
        lblTimeStretchRateValue.stringValue = rateString
        
        timeOverlapSlider.floatValue = overlap
        lblTimeOverlapValue.stringValue = overlapString
    }
    
    // Updates the label that displays the pitch shift value
    func updatePitchShift(_ shiftPitchString: String) {
        lblPitchShiftValue.stringValue = shiftPitchString
    }
    
    // Sets the playback rate to a specific value
    func setRate(_ rate: Float, _ rateString: String, _ shiftPitchString: String) {
        
        lblTimeStretchRateValue.stringValue = rateString
        timeSlider.floatValue = rate
        updatePitchShift(shiftPitchString)
    }
    
    func setOverlap(_ overlap: Float, _ overlapString: String) {
        
        timeOverlapSlider.floatValue = overlap
        lblTimeOverlapValue.stringValue = overlapString
    }
    
    func applyPreset(_ preset: TimeStretchPreset) {
        
        setUnitState(preset.state)
        btnShiftPitch.onIf(preset.shiftPitch)
        
        // TODO: Move this calculation to a new util functions class/file
        let shiftedPitch = (preset.shiftPitch ? 1200 * log2(preset.rate) : 0) * ValueConversions.pitch_audioGraphToUI
        lblPitchShiftValue.stringValue = ValueFormatter.formatPitch(shiftedPitch)
        
        timeSlider.floatValue = preset.rate
        lblTimeStretchRateValue.stringValue = ValueFormatter.formatTimeStretchRate(preset.rate)
        
        timeOverlapSlider.floatValue = preset.overlap
        lblTimeOverlapValue.stringValue = ValueFormatter.formatOverlap(preset.overlap)
    }
    
    func redrawSliders() {
        [timeSlider, timeOverlapSlider].forEach({$0?.redraw()})
    }
    
    func changeFunctionCaptionTextColor() {
        
        btnShiftPitch.image = btnShiftPitch.image?.filledWithColor(Colors.Effects.functionCaptionTextColor)
        btnShiftPitch.alternateImage = btnShiftPitch.alternateImage?.filledWithColor(Colors.Effects.functionCaptionTextColor)
        
        btnShiftPitch.redraw()
    }
}
