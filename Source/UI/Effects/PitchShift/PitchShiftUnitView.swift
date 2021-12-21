//
//  PitchShiftUnitView.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class PitchShiftUnitView: NSView {
    
    // ------------------------------------------------------------------------
    
    // MARK: UI fields

    @IBOutlet weak var pitchSlider: EffectsUnitSlider!
    
    @IBOutlet weak var lblOctaves: NSTextField!
    @IBOutlet weak var lblSemitones: NSTextField!
    @IBOutlet weak var lblCents: NSTextField!
    
    private var sliders: [EffectsUnitSlider] = []
    
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
        
        lblOctaves.stringValue = "\(integerWithSign(pitch.octaves))"
        lblSemitones.stringValue = "\(integerWithSign(pitch.semitones))"
        lblCents.stringValue = "\(integerWithSign(pitch.cents))"
    }
    
    private func integerWithSign(_ integer: Int) -> String {
        
        if integer > 0 {
            return "+\(integer)"
        }
        
        if integer == 0 {
            return "0"
        }
        
        return "\(integer)"
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: View initialization
    
    override func awakeFromNib() {
        sliders = [pitchSlider]
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
    
    func pitchUpdated() -> PitchShift {
        
        let newPitch = self.pitch
        updateLabels(pitch: newPitch)
        return newPitch
    }
    
    func stateChanged() {
        sliders.forEach {$0.updateState()}
    }
    
    func applyPreset(_ preset: PitchShiftPreset) {
        
        pitch = PitchShift(fromCents: preset.pitch)
        setUnitState(preset.state)
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Theming
    
    func redrawSliders() {
        sliders.forEach {$0.redraw()}
    }
}
