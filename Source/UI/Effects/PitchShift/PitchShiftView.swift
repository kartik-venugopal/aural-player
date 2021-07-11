//
//  PitchView.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class PitchShiftView: NSView {

    @IBOutlet weak var pitchSlider: EffectsUnitSlider!
    @IBOutlet weak var pitchOverlapSlider: EffectsUnitSlider!
    @IBOutlet weak var lblPitchValue: NSTextField!
    @IBOutlet weak var lblPitchOverlapValue: NSTextField!
    
    private var sliders: [EffectsUnitSlider] = []
    
    var pitch: Float {
        return pitchSlider.floatValue
    }
    
    var overlap: Float {
        return pitchOverlapSlider.floatValue
    }
    
    override func awakeFromNib() {
        sliders = [pitchSlider, pitchOverlapSlider]
    }
    
    func initialize(_ stateFunction: @escaping () -> EffectsUnitState) {
        
        sliders.forEach({
            $0.stateFunction = stateFunction
            $0.updateState()
        })
    }
    
    func setState(_ pitch: Float, _ pitchString: String, _ overlap: Float, _ overlapString: String) {
        
        setPitch(pitch, pitchString)
        setPitchOverlap(overlap, overlapString)
    }
    
    func setUnitState(_ state: EffectsUnitState) {
        sliders.forEach({$0.setUnitState(state)})
    }
    
    func setPitch(_ pitch: Float, _ pitchString: String) {
        
        pitchSlider.floatValue = pitch
        lblPitchValue.stringValue = pitchString
    }
    
    func setPitchOverlap(_ overlap: Float, _ overlapString: String) {
        
        pitchOverlapSlider.floatValue = overlap
        lblPitchOverlapValue.stringValue = overlapString
    }
    
    func stateChanged() {
        sliders.forEach({$0.updateState()})
    }
    
    func applyPreset(_ preset: PitchShiftPreset) {
        
        let pitch = preset.pitch * ValueConversions.pitch_audioGraphToUI
        setPitch(pitch, ValueFormatter.formatPitch(pitch))
        setPitchOverlap(preset.overlap, ValueFormatter.formatOverlap(preset.overlap))
        setUnitState(preset.state)
    }
    
    func redrawSliders() {
        [pitchSlider, pitchOverlapSlider].forEach({$0?.redraw()})
    }
}
