//
//  PitchShiftUnitViewController.swift
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
class PitchShiftUnitViewController: EffectsUnitViewController {
    
    override var nibName: String? {"PitchShiftUnit"}
    
    // ------------------------------------------------------------------------
    
    // MARK: UI fields
    
    @IBOutlet weak var pitchShiftUnitView: PitchShiftUnitView!
    
    // ------------------------------------------------------------------------
    
    // MARK: Services, utilities, and helper objects
    
    private var pitchShiftUnit: PitchShiftUnitDelegateProtocol = objectGraph.audioGraphDelegate.pitchShiftUnit
    
    // ------------------------------------------------------------------------
    
    // MARK: UI initialization / life-cycle
 
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        effectsUnit = pitchShiftUnit
        presetsWrapper = PresetsWrapper<PitchShiftPreset, PitchShiftPresets>(pitchShiftUnit.presets)
    }
    
    override func oneTimeSetup() {
        
        super.oneTimeSetup()
        pitchShiftUnitView.initialize(stateFunction: unitStateFunction)
    }
    
    override func initControls() {
        
        super.initControls()
        
        pitchShiftUnitView.setState(pitch: pitchShiftUnit.pitch, pitchString: pitchShiftUnit.formattedPitch,
                                    overlap: pitchShiftUnit.overlap, overlapString: pitchShiftUnit.formattedOverlap)
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Actions
    
    // Updates the pitch
    @IBAction func pitchAction(_ sender: AnyObject) {
        
        pitchShiftUnit.pitch = pitchShiftUnitView.pitch
        pitchShiftUnitView.setPitch(pitchShiftUnit.pitch, pitchString: pitchShiftUnit.formattedPitch)
    }
    
    // Updates the pitch overlap parameter of the Pitch shift effects unit
    @IBAction func pitchOverlapAction(_ sender: AnyObject) {

        pitchShiftUnit.overlap = pitchShiftUnitView.overlap
        pitchShiftUnitView.setPitchOverlap(pitchShiftUnit.overlap, overlapString: pitchShiftUnit.formattedOverlap)
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Message handling
    
    override func initSubscriptions() {
        
        super.initSubscriptions()
        
        messenger.subscribe(to: .pitchEffectsUnit_decreasePitch, handler: decreasePitch)
        messenger.subscribe(to: .pitchEffectsUnit_increasePitch, handler: increasePitch)
        messenger.subscribe(to: .pitchEffectsUnit_setPitch, handler: setPitch(_:))
    }
    
    override func stateChanged() {
        
        super.stateChanged()
        pitchShiftUnitView.stateChanged()
    }
    
    // Sets the pitch to a specific value
    private func setPitch(_ pitch: Float) {
        
        pitchShiftUnit.pitch = pitch
        pitchShiftUnit.ensureActive()
        
        pitchShiftUnitView.setPitch(pitch, pitchString: pitchShiftUnit.formattedPitch)
        
        btnBypass.updateState()
        pitchShiftUnitView.stateChanged()
        
        messenger.publish(.effects_unitStateChanged)
        
        // Show the Pitch tab
        showThisTab()
    }
    
    // Increases the overall pitch by a certain preset increment
    private func increasePitch() {
        
        let newPitch = pitchShiftUnit.increasePitch()
        pitchChange(newPitch.pitch, pitchString: newPitch.pitchString)
    }
    
    // Decreases the overall pitch by a certain preset decrement
    private func decreasePitch() {
        
        let newPitch = pitchShiftUnit.decreasePitch()
        pitchChange(newPitch.pitch, pitchString: newPitch.pitchString)
    }
    
    // Changes the pitch to a specified value
    private func pitchChange(_ pitch: Float, pitchString: String) {
        
        messenger.publish(.effects_unitStateChanged)
        
        pitchShiftUnitView.setPitch(pitch, pitchString: pitchString)
        pitchShiftUnitView.stateChanged()
        
        // Show the Pitch tab if the Effects panel is shown
        showThisTab()
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Theming
    
    override func applyColorScheme(_ scheme: ColorScheme) {
        
        super.applyColorScheme(scheme)
        changeSliderColors()
    }
    
    override func changeSliderColors() {
        pitchShiftUnitView.redrawSliders()
    }
    
    override func changeActiveUnitStateColor(_ color: NSColor) {
        
        super.changeActiveUnitStateColor(color)
        
        if pitchShiftUnit.isActive {
            pitchShiftUnitView.redrawSliders()
        }
    }
    
    override func changeBypassedUnitStateColor(_ color: NSColor) {
        
        super.changeBypassedUnitStateColor(color)
        
        if pitchShiftUnit.state == .bypassed {
            pitchShiftUnitView.redrawSliders()
        }
    }
    
    override func changeSuppressedUnitStateColor(_ color: NSColor) {
        
        super.changeSuppressedUnitStateColor(color)
        
        if pitchShiftUnit.state == .suppressed {
            pitchShiftUnitView.redrawSliders()
        }
    }
}
