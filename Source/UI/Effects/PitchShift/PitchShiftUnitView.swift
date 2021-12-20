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
    @IBOutlet weak var lblPitchValue: NSTextField!
    
    private var sliders: [EffectsUnitSlider] = []
    
    // ------------------------------------------------------------------------
    
    // MARK: Properties
    
    var pitch: Float {
        pitchSlider.floatValue
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
    
    func setState(pitch: Float, pitchString: String) {
        setPitch(pitch, pitchString: pitchString)
    }
    
    func setUnitState(_ state: EffectsUnitState) {
        sliders.forEach {$0.setUnitState(state)}
    }
    
    func setPitch(_ pitch: Float, pitchString: String) {
        
        pitchSlider.floatValue = pitch
        lblPitchValue.stringValue = pitchString
    }
    
    func stateChanged() {
        sliders.forEach {$0.updateState()}
    }
    
    func applyPreset(_ preset: PitchShiftPreset) {
        
        let pitch = preset.pitch * ValueConversions.pitch_audioGraphToUI
        setPitch(pitch, pitchString: ValueFormatter.formatPitch(pitch))
        setUnitState(preset.state)
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Theming
    
    func redrawSliders() {
        sliders.forEach {$0.redraw()}
    }
}
