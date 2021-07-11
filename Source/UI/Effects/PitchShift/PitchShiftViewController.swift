//
//  PitchViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    View controller for the Pitch effects unit
 */
class PitchShiftViewController: EffectsUnitViewController {
    
    @IBOutlet weak var pitchView: PitchShiftView!
    @IBOutlet weak var box: NSBox!
    
    @IBOutlet weak var lblPitch: VALabel!
    @IBOutlet weak var lblPitchMin: VALabel!
    @IBOutlet weak var lblPitchMax: VALabel!
    @IBOutlet weak var lblPitchValue: VALabel!
    
    @IBOutlet weak var lblOverlap: VALabel!
    @IBOutlet weak var lblOverlapMin: VALabel!
    @IBOutlet weak var lblOverlapMax: VALabel!
    @IBOutlet weak var lblPitchOverlapValue: VALabel!
    
    override var nibName: String? {"PitchShift"}
    
    private var pitchShiftUnit: PitchShiftUnitDelegateProtocol = ObjectGraph.audioGraphDelegate.pitchShiftUnit
 
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        // TODO: Could some of this move to AudioGraphDelegate ??? e.g. graph.getUnit(self.unitType) OR graph.getStateFunction(self.unitTyp
        unitType = .pitch
        effectsUnit = pitchShiftUnit
        presetsWrapper = PresetsWrapper<PitchShiftPreset, PitchShiftPresets>(pitchShiftUnit.presets)
    }
    
    override func initSubscriptions() {
        
        super.initSubscriptions()
        
        Messenger.subscribe(self, .pitchEffectsUnit_decreasePitch, self.decreasePitch)
        Messenger.subscribe(self, .pitchEffectsUnit_increasePitch, self.increasePitch)
        Messenger.subscribe(self, .pitchEffectsUnit_setPitch, self.setPitch(_:))
    }
    
    override func oneTimeSetup() {
        
        super.oneTimeSetup()
        
        // TODO: Move this to a generic view
        pitchView.initialize(self.unitStateFunction)
        
        functionLabels = [lblPitch, lblOverlap, lblPitchMin, lblPitchMax, lblPitchValue, lblOverlapMin, lblOverlapMax, lblPitchOverlapValue]
    }
    
    override func initControls() {
        
        super.initControls()
        pitchView.setState(pitchShiftUnit.pitch, pitchShiftUnit.formattedPitch, pitchShiftUnit.overlap, pitchShiftUnit.formattedOverlap)
    }
    
    override func stateChanged() {
        
        super.stateChanged()
        pitchView.stateChanged()
    }
    
    // Updates the pitch
    @IBAction func pitchAction(_ sender: AnyObject) {
        
        pitchShiftUnit.pitch = pitchView.pitch
        pitchView.setPitch(pitchShiftUnit.pitch, pitchShiftUnit.formattedPitch)
    }
    
    // Sets the pitch to a specific value
    private func setPitch(_ pitch: Float) {
        
        pitchShiftUnit.pitch = pitch
        pitchShiftUnit.ensureActive()
        
        pitchView.setPitch(pitch, pitchShiftUnit.formattedPitch)
        
        btnBypass.updateState()
        pitchView.stateChanged()
        
        Messenger.publish(.effects_unitStateChanged)
        
        // Show the Pitch tab
        showThisTab()
    }
    
    // Updates the Overlap parameter of the Pitch shift effects unit
    @IBAction func pitchOverlapAction(_ sender: AnyObject) {

        pitchShiftUnit.overlap = pitchView.overlap
        pitchView.setPitchOverlap(pitchShiftUnit.overlap, pitchShiftUnit.formattedOverlap)
    }
    
    // Increases the overall pitch by a certain preset increment
    private func increasePitch() {
        
        let newPitch = pitchShiftUnit.increasePitch()
        pitchChange(newPitch.pitch, newPitch.pitchString)
    }
    
    // Decreases the overall pitch by a certain preset decrement
    private func decreasePitch() {
        
        let newPitch = pitchShiftUnit.decreasePitch()
        pitchChange(newPitch.pitch, newPitch.pitchString)
    }
    
    // Changes the pitch to a specified value
    private func pitchChange(_ pitch: Float, _ pitchString: String) {
        
        Messenger.publish(.effects_unitStateChanged)
        
        pitchView.setPitch(pitch, pitchString)
        pitchView.stateChanged()
        
        // Show the Pitch tab if the Effects panel is shown
        showThisTab()
    }
    
    override func applyColorScheme(_ scheme: ColorScheme) {
        
        super.applyColorScheme(scheme)
        changeSliderColors()
    }
    
    override func changeSliderColors() {
        pitchView.redrawSliders()
    }
    
    override func changeActiveUnitStateColor(_ color: NSColor) {
        
        super.changeActiveUnitStateColor(color)
        
        if pitchShiftUnit.isActive {
            pitchView.redrawSliders()
        }
    }
    
    override func changeBypassedUnitStateColor(_ color: NSColor) {
        
        super.changeBypassedUnitStateColor(color)
        
        if pitchShiftUnit.state == .bypassed {
            pitchView.redrawSliders()
        }
    }
    
    override func changeSuppressedUnitStateColor(_ color: NSColor) {
        
        super.changeSuppressedUnitStateColor(color)
        
        if pitchShiftUnit.state == .suppressed {
            pitchView.redrawSliders()
        }
    }
}
