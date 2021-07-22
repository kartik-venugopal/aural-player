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
    
    @IBOutlet weak var timeSlider: EffectsUnitSlider!
    @IBOutlet weak var timeOverlapSlider: EffectsUnitSlider!
    
    @IBOutlet weak var btnShiftPitch: NSButton!
    
    @IBOutlet weak var lblTimeStretchRateValue: NSTextField!
    @IBOutlet weak var lblPitchShiftValue: NSTextField!
    @IBOutlet weak var lblTimeOverlapValue: NSTextField!
    
    private var sliders: [EffectsUnitSlider] = []
    
    // ------------------------------------------------------------------------
    
    // MARK: Properties
    
    var rate: Float {
        timeSlider.floatValue
    }
    
    var overlap: Float {
        timeOverlapSlider.floatValue
    }
    
    var shiftPitch: Bool {
        btnShiftPitch.isOn
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: View initialization
    
    override func awakeFromNib() {
        sliders = [timeSlider, timeOverlapSlider]
    }
    
    func initialize(stateFunction: @escaping EffectsUnitStateFunction) {
        
        sliders.forEach {
            $0.stateFunction = stateFunction
        }
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: View update
    
    func setUnitState(_ state: EffectsUnitState) {
        sliders.forEach {$0.setUnitState(state)}
    }
    
    func stateChanged() {
        sliders.forEach {$0.updateState()}
    }
    
    func setState(rate: Float, rateString: String,
                  overlap: Float, overlapString: String,
                  shiftPitch: Bool, shiftPitchString: String) {
        
        btnShiftPitch.onIf(shiftPitch)
        updatePitchShift(shiftPitchString: shiftPitchString)
        
        timeSlider.floatValue = rate
        lblTimeStretchRateValue.stringValue = rateString
        
        timeOverlapSlider.floatValue = overlap
        lblTimeOverlapValue.stringValue = overlapString
    }
    
    // Updates the label that displays the pitch shift value
    func updatePitchShift(shiftPitchString: String) {
        lblPitchShiftValue.stringValue = shiftPitchString
    }
    
    // Sets the playback rate to a specific value
    func setRate(_ rate: Float, rateString: String, shiftPitchString: String) {
        
        lblTimeStretchRateValue.stringValue = rateString
        timeSlider.floatValue = rate
        updatePitchShift(shiftPitchString: shiftPitchString)
    }
    
    func setOverlap(_ overlap: Float, overlapString: String) {
        
        timeOverlapSlider.floatValue = overlap
        lblTimeOverlapValue.stringValue = overlapString
    }
    
    func applyPreset(_ preset: TimeStretchPreset) {
        
        setUnitState(preset.state)
        btnShiftPitch.onIf(preset.shiftPitch)
        
        lblPitchShiftValue.stringValue = ValueFormatter.formatPitch(preset.shiftedPitch)
        
        timeSlider.floatValue = preset.rate
        lblTimeStretchRateValue.stringValue = ValueFormatter.formatTimeStretchRate(preset.rate)
        
        timeOverlapSlider.floatValue = preset.overlap
        lblTimeOverlapValue.stringValue = ValueFormatter.formatOverlap(preset.overlap)
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
        [timeSlider, timeOverlapSlider].forEach {$0?.redraw()}
    }
    
    func changeFunctionCaptionTextColor() {
        
        btnShiftPitch.image = btnShiftPitch.image?.filledWithColor(Colors.Effects.functionCaptionTextColor)
        btnShiftPitch.alternateImage = btnShiftPitch.alternateImage?.filledWithColor(Colors.Effects.functionCaptionTextColor)
        
        btnShiftPitch.redraw()
    }
}
