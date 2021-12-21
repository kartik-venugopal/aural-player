//
//  TimeStretchUnitView.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class TimeStretchUnitView: NSView {
    
    // ------------------------------------------------------------------------
    
    // MARK: UI fields
    
    @IBOutlet weak var timeSlider: TimeStretchSlider!
    
    @IBOutlet weak var btnShiftPitch: NSButton!
    
    @IBOutlet weak var lblTimeStretchRateValue: NSTextField!
    @IBOutlet weak var lblPitchShiftValue: NSTextField!
    
    // ------------------------------------------------------------------------
    
    // MARK: Properties
    
    var rate: Float {
        timeSlider.rate
    }
    
    var shiftPitch: Bool {
        btnShiftPitch.isOn
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: View initialization
    
    func initialize(stateFunction: @escaping EffectsUnitStateFunction) {
        timeSlider.stateFunction = stateFunction
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: View update
    
    func setUnitState(_ state: EffectsUnitState) {
        timeSlider.setUnitState(state)
    }
    
    func stateChanged() {
        timeSlider.updateState()
    }
    
    func setState(rate: Float, rateString: String,
                  shiftPitch: Bool, shiftPitchString: String) {
        
        btnShiftPitch.onIf(shiftPitch)
        updatePitchShift(shiftPitchString: shiftPitchString)
        
        timeSlider.rate = rate
        lblTimeStretchRateValue.stringValue = rateString
    }
    
    // Updates the label that displays the pitch shift value
    func updatePitchShift(shiftPitchString: String) {
        lblPitchShiftValue.stringValue = shiftPitchString
    }
    
    // Sets the playback rate to a specific value
    func setRate(_ rate: Float, rateString: String, shiftPitchString: String) {
        
        lblTimeStretchRateValue.stringValue = rateString
        timeSlider.rate = rate
        updatePitchShift(shiftPitchString: shiftPitchString)
    }
    
    func applyPreset(_ preset: TimeStretchPreset) {
        
        setUnitState(preset.state)
        btnShiftPitch.onIf(preset.shiftPitch)
        
        lblPitchShiftValue.stringValue = ValueFormatter.formatPitch(preset.shiftedPitch)
        
        timeSlider.rate = preset.rate
        lblTimeStretchRateValue.stringValue = ValueFormatter.formatTimeStretchRate(preset.rate)
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Theming
    
    func applyFontScheme(_ fontScheme: FontScheme) {
        btnShiftPitch.redraw()
    }
    
    func applyColorScheme(_ scheme: ColorScheme) {
        
        redrawSliders()
        
        btnShiftPitch.attributedTitle = NSAttributedString(string: btnShiftPitch.title,
                                                           attributes: [.foregroundColor: scheme.effects.functionCaptionTextColor])
        
        btnShiftPitch.attributedAlternateTitle = NSAttributedString(string: btnShiftPitch.title,
                                                                    attributes: [.foregroundColor: scheme.effects.functionCaptionTextColor])
    }
    
    func redrawSliders() {
        timeSlider.redraw()
    }
    
    func changeFunctionCaptionTextColor() {
        
        btnShiftPitch.image = btnShiftPitch.image?.filledWithColor(Colors.Effects.functionCaptionTextColor)
        btnShiftPitch.alternateImage = btnShiftPitch.alternateImage?.filledWithColor(Colors.Effects.functionCaptionTextColor)
        
        btnShiftPitch.redraw()
    }
}
