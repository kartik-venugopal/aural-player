//
//  TimeStretchUnitView.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class TimeStretchUnitView: NSView {
    
    // ------------------------------------------------------------------------
    
    // MARK: UI fields
    
    @IBOutlet weak var timeSlider: CircularSlider!
    
    @IBOutlet weak var btnShiftPitch: EffectsUnitToggle!
    
    @IBOutlet weak var lblTimeStretchRateValue: NSTextField!
    
    // ------------------------------------------------------------------------
    
    // MARK: Properties
    
    var rate: Float {
        timeSlider.floatValue
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        timeSlider.effectsUnit = audioGraph.timeStretchUnit
        
        fxUnitStateObserverRegistry.registerObserver(timeSlider, forFXUnit: audioGraph.timeStretchUnit)
        fxUnitStateObserverRegistry.registerObserver(btnShiftPitch, forFXUnit: audioGraph.timeStretchUnit)
        
        timeSlider.allowedValues = 0.25...4
        
        timeSlider.valueFunction = {(angle: CGFloat, arcRange: CGFloat, allowedValues: ClosedRange<Float>) in
            
            let minValue = allowedValues.lowerBound
            let maxValue = allowedValues.upperBound
            return minValue * powf(2, Float(angle) * log2f(maxValue / minValue) / Float(arcRange))
        }
        
        timeSlider.angleFunction = {(value: Float, arcRange: CGFloat, allowedValues: ClosedRange<Float>) in
            
            let minValue = allowedValues.lowerBound
            let maxValue = allowedValues.upperBound
            return CGFloat(log2f(value / minValue) * Float(arcRange) / log2f(maxValue / minValue))
        }
        
        timeSlider.setTicks(valuesAndTolerances: [(0.25, 0.01), (0.5, 0.05), (1, 0.05), (2, 0.1), (3, 0.1), (4, 0.1)])
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: View update
    
    func setState(rate: Float, rateString: String,
                  shiftPitch: Bool, shiftPitchString: String) {
        
        btnShiftPitch.onIf(shiftPitch)
        
        timeSlider.setValue(rate)
        lblTimeStretchRateValue.stringValue = rateString
    }
    
    // Sets the playback rate to a specific value
    func setRate(_ rate: Float, rateString: String, shiftPitchString: String) {
        
        lblTimeStretchRateValue.stringValue = rateString
        timeSlider.setValue(rate)
    }
    
    func applyPreset(_ preset: TimeStretchPreset) {
        
        btnShiftPitch.onIf(preset.shiftPitch)
        
        timeSlider.setValue(preset.rate)
        lblTimeStretchRateValue.stringValue = ValueFormatter.formatTimeStretchRate(preset.rate)
    }
    
    func colorChanged(forUnitState unitState: EffectsUnitState) {
        
        timeSlider.redraw()
        btnShiftPitch.redraw(forState: unitState)
    }
}
