//
//  PitchShiftUnitViewController.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
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
    
    // MARK: Services, utilities, helpers, and properties
    
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
        pitchShiftUnitView.pitch = pitchShiftUnit.pitch
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Actions
    
    // Updates the pitch
    @IBAction func pitchAction(_ sender: AnyObject) {
        pitchShiftUnit.pitch = pitchShiftUnitView.pitchUpdated()
    }
    
    @IBAction func increasePitchByOctaveAction(_ sender: AnyObject) {
        pitchShiftUnitView.pitch = pitchShiftUnit.increasePitchOneOctave()
    }
    
    @IBAction func increasePitchBySemitoneAction(_ sender: AnyObject) {
        pitchShiftUnitView.pitch = pitchShiftUnit.increasePitchOneSemitone()
    }
    
    @IBAction func increasePitchByCentAction(_ sender: AnyObject) {
        pitchShiftUnitView.pitch = pitchShiftUnit.increasePitchOneCent()
    }
    
    @IBAction func decreasePitchByOctaveAction(_ sender: AnyObject) {
        pitchShiftUnitView.pitch = pitchShiftUnit.decreasePitchOneOctave()
    }
    
    @IBAction func decreasePitchBySemitoneAction(_ sender: AnyObject) {
        pitchShiftUnitView.pitch = pitchShiftUnit.decreasePitchOneSemitone()
    }
    
    @IBAction func decreasePitchByCentAction(_ sender: AnyObject) {
        pitchShiftUnitView.pitch = pitchShiftUnit.decreasePitchOneCent()
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
        
        let newPitch = PitchShift(fromCents: pitch)
        
        pitchShiftUnit.pitch = newPitch
        pitchShiftUnit.ensureActive()
        
        pitchShiftUnitView.pitch = newPitch
        
        btnBypass.updateState()
        pitchShiftUnitView.stateChanged()
        
        messenger.publish(.effects_unitStateChanged)
        
        // Show the Pitch tab
        showThisTab()
    }
    
    // Increases the overall pitch by a certain preset increment
    private func increasePitch() {
        pitchChange(pitchShiftUnit.increasePitch())
    }
    
    // Decreases the overall pitch by a certain preset decrement
    private func decreasePitch() {
        pitchChange(pitchShiftUnit.decreasePitch())
    }
    
    // Changes the pitch to a specified value
    private func pitchChange(_ pitch: PitchShift) {
        
        messenger.publish(.effects_unitStateChanged)
        
        pitchShiftUnitView.pitch = pitch
        pitchShiftUnitView.stateChanged()
        
        // Show the Pitch tab if the Effects panel is shown
        showThisTab()
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Theming
    
    override func applyColorScheme(_ scheme: ColorScheme) {
        
        super.applyColorScheme(scheme)
        pitchShiftUnitView.applyColorScheme(scheme)
    }
    
    override func changeSliderColors() {
        pitchShiftUnitView.redrawSliders()
    }
    
    override func changeFunctionButtonColor(_ color: NSColor) {
        
        super.changeFunctionButtonColor(color)
        pitchShiftUnitView.changeFunctionButtonColor(color)
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
