//
//  PitchShiftUnitView.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class PitchShiftUnitView: NSView {
    
    // ------------------------------------------------------------------------
    
    // MARK: UI fields

    @IBOutlet weak var pitchSlider: CircularSlider!
    
    @IBOutlet weak var lblOctaves: NSTextField!
    @IBOutlet weak var lblSemitones: NSTextField!
    @IBOutlet weak var lblCents: NSTextField!
    
    var pitchShiftUnit: PitchShiftUnitProtocol {
        audioGraph.pitchShiftUnit
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        pitchSlider.effectsUnit = pitchShiftUnit
//        fxUnitStateObserverRegistry.registerObserver(pitchSlider, forFXUnit: pitchShiftUnit)
        
        let minPitch = pitchShiftUnit.minPitch
        let maxPitch = pitchShiftUnit.maxPitch
        pitchSlider.allowedValues = minPitch...maxPitch
        
        pitchSlider.valueFunction = {(angle: CGFloat, arcRange: CGFloat, allowedValues: ClosedRange<Float>) in
            
            let minValue = allowedValues.lowerBound
            let maxValue = allowedValues.upperBound
            return minValue + Float(angle / arcRange) * (maxValue - minValue)
        }
        
        pitchSlider.angleFunction = {(value: Float, arcRange: CGFloat, allowedValues: ClosedRange<Float>) in
            
            let minValue = allowedValues.lowerBound
            let maxValue = allowedValues.upperBound
            return CGFloat((value - minValue) * Float(arcRange) / (maxValue - minValue))
        }
        
        pitchSlider.setTicks(valuesAndTolerances: [(-2400, 200), (-1200, 200), (0, 100), (1200, 200), (2400, 200)])
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Properties
    
    var pitch: PitchShift {
        
        get {
            PitchShift(fromCents: pitchSlider.integerValue)
        }
        
        set {
            
            pitchSlider.integerValue = newValue.asCents
            updateLabels(pitch: newValue)
        }
    }
    
    private func updateLabels(pitch: PitchShift) {
        
        lblOctaves.stringValue = "\(pitch.octaves.signedString)"
        lblSemitones.stringValue = "\(pitch.semitones.signedString)"
        lblCents.stringValue = "\(pitch.cents.signedString)"
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: View update
    
    func pitchUpdated() -> PitchShift {
        
        let newPitch = self.pitch
        updateLabels(pitch: newPitch)
        return newPitch
    }
    
    func applyPreset(_ preset: PitchShiftPreset) {
        pitch = PitchShift(fromCents: preset.pitch)
    }
}
