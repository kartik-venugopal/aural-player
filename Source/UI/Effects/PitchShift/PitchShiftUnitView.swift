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
    @IBOutlet weak var pitchOverlapSlider: EffectsUnitSlider!
    @IBOutlet weak var lblPitchValue: NSTextField!
    @IBOutlet weak var lblPitchOverlapValue: NSTextField!
    
    private var sliders: [EffectsUnitSlider] = []
    
    // ------------------------------------------------------------------------
    
    // MARK: Properties
    
    var pitch: Float {
        pitchSlider.floatValue
    }
    
    var overlap: Float {
        pitchOverlapSlider.floatValue
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: View initialization
    
    override func awakeFromNib() {
        sliders = [pitchSlider, pitchOverlapSlider]
    }
    
    func initialize(stateFunction: @escaping EffectsUnitStateFunction) {
        
        sliders.forEach {
            $0.stateFunction = stateFunction
        }
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: View update
    
    func setState(pitch: Float, pitchString: String, overlap: Float, overlapString: String) {
        
        setPitch(pitch, pitchString: pitchString)
        setPitchOverlap(overlap, overlapString: overlapString)
    }
    
    func setUnitState(_ state: EffectsUnitState) {
        sliders.forEach {$0.setUnitState(state)}
    }
    
    func setPitch(_ pitch: Float, pitchString: String) {
        
        pitchSlider.floatValue = pitch
        lblPitchValue.stringValue = pitchString
    }
    
    func setPitchOverlap(_ overlap: Float, overlapString: String) {
        
        pitchOverlapSlider.floatValue = overlap
        lblPitchOverlapValue.stringValue = overlapString
    }
    
    func stateChanged() {
        sliders.forEach {$0.updateState()}
    }
    
    func applyPreset(_ preset: PitchShiftPreset) {
        
        let pitch = preset.pitch * ValueConversions.pitch_audioGraphToUI
        setPitch(pitch, pitchString: ValueFormatter.formatPitch(pitch))
        setPitchOverlap(preset.overlap, overlapString: ValueFormatter.formatOverlap(preset.overlap))
        setUnitState(preset.state)
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Theming
    
    func redrawSliders() {
        sliders.forEach {$0.redraw()}
    }
}
