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
    
    @IBOutlet weak var octavesSlider: TickedCircularSlider!
    @IBOutlet weak var semitonesSlider: TickedCircularSlider!
    @IBOutlet weak var centsSlider: TickedCircularSlider!
    
    @IBOutlet weak var lblOctaves: NSTextField!
    @IBOutlet weak var lblSemitones: NSTextField!
    @IBOutlet weak var lblCents: NSTextField!

    private var sliders: [TickedCircularSlider] = []
    private var labels: [NSTextField] = []
    
    // ------------------------------------------------------------------------
    
    // MARK: Properties
    
    var pitch: PitchShift {
        
        get {
        
            applyCorrection()
            
            return PitchShift(octaves: octavesSlider.integerValue,
                              semitones: semitonesSlider.integerValue,
                              cents: centsSlider.integerValue)
        }
        
        set {
            
            octavesSlider.setValue(newValue.octaves)
            semitonesSlider.setValue(newValue.semitones)
            centsSlider.setValue(newValue.cents)
            
            applyCorrection()
            pitchUpdated()
        }
    }
    
    private func applyCorrection() {
        
        let octaves = octavesSlider.integerValue
        let semitones = semitonesSlider.integerValue
        
        switch octaves {
            
        case -2:
            
            // Semitones can only be non-negative
            semitonesSlider.allowedValues = 0...12
            
            if semitonesSlider.integerValue == 0 {
                centsSlider.allowedValues = 0...100
            }
            
        case -1:
            
            semitonesSlider.allowedValues = -12...12
            centsSlider.allowedValues = semitones == -12 ? 0...100 : -100...100
            
        case 1:
            
            semitonesSlider.allowedValues = -12...12
            centsSlider.allowedValues = semitones == 12 ? -100...0 : -100...100

        case 2:
            
            semitonesSlider.allowedValues = -12...0
            
            if semitonesSlider.integerValue == 0 {
                centsSlider.allowedValues = -100...0
            }

        default:
            
            semitonesSlider.allowedValues = -12...12
            centsSlider.allowedValues = -100...100
        }
    }
    
    func setUnitState(_ state: EffectsUnitState) {
        sliders.forEach {$0.unitState = state}
    }
    
    func pitchUpdated() {
        
        lblOctaves.stringValue = String(octavesSlider.integerValue)
        lblSemitones.stringValue = String(semitonesSlider.integerValue)
        lblCents.stringValue = String(centsSlider.integerValue)
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: View initialization
    
    override func awakeFromNib() {
        sliders = [octavesSlider, semitonesSlider, centsSlider]
    }
    
    func initialize(stateFunction: @escaping EffectsUnitStateFunction) {
        
        sliders.forEach {
            $0.stateFunction = stateFunction
        }
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: View update
    
    func stateChanged() {
        sliders.forEach {$0.updateState()}
    }
    
    func applyPreset(_ preset: PitchShiftPreset) {
        
//        self.pitch = preset.pitch * ValueConversions.pitch_audioGraphToUI
        setUnitState(preset.state)
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Theming
    
    func redrawSliders() {
        sliders.forEach {$0.redraw()}
    }
}
