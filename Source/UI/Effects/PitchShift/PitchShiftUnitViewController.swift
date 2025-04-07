//
//  PitchShiftUnitViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    View controller for the Pitch effects unit
 */
class PitchShiftUnitViewController: EffectsUnitViewController {
    
    override var nibName: NSNib.Name? {"PitchShiftUnit"}
    
    // ------------------------------------------------------------------------
    
    // MARK: UI fields
    
    @IBOutlet weak var pitchShiftUnitView: PitchShiftUnitView!
    @IBOutlet weak var pitchSlider: CircularSlider!
    
    // ------------------------------------------------------------------------
    
    // MARK: Services, utilities, helpers, and properties
    
    private var pitchShiftUnit: PitchShiftUnitProtocol = audioGraph.pitchShiftUnit
    
    // ------------------------------------------------------------------------
    
    // MARK: UI initialization / life-cycle
 
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        effectsUnit = pitchShiftUnit
        presetsWrapper = PresetsWrapper<PitchShiftPreset, PitchShiftPresets>(pitchShiftUnit.presets)
        
        pitchSlider.effectsUnit = pitchShiftUnit
        fxUnitStateObserverRegistry.registerObserver(pitchSlider, forFXUnit: pitchShiftUnit)
        
        pitchShiftUnitView.initialize(minPitch: pitchShiftUnit.minPitch,
                                      maxPitch: pitchShiftUnit.maxPitch)
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
        pitchShiftUnitView.pitch = pitchShiftUnit.increasePitchByOctave()
    }
    
    @IBAction func increasePitchBySemitoneAction(_ sender: AnyObject) {
        pitchShiftUnitView.pitch = pitchShiftUnit.increasePitchBySemitone()
    }
    
    @IBAction func increasePitchByCentAction(_ sender: AnyObject) {
        pitchShiftUnitView.pitch = pitchShiftUnit.increasePitchByCent()
    }
    
    @IBAction func decreasePitchByOctaveAction(_ sender: AnyObject) {
        pitchShiftUnitView.pitch = pitchShiftUnit.decreasePitchByOctave()
    }
    
    @IBAction func decreasePitchBySemitoneAction(_ sender: AnyObject) {
        pitchShiftUnitView.pitch = pitchShiftUnit.decreasePitchBySemitone()
    }
    
    @IBAction func decreasePitchByCentAction(_ sender: AnyObject) {
        pitchShiftUnitView.pitch = pitchShiftUnit.decreasePitchByCent()
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Message handling
    
    override func initSubscriptions() {
        
        super.initSubscriptions()
        messenger.subscribe(to: .Effects.PitchShiftUnit.pitchUpdated, handler: pitchUpdated)
    }

    // Changes the pitch to a specified value
    private func pitchUpdated() {
        
        messenger.publish(.Effects.unitStateChanged)
        
        pitchShiftUnitView.pitch = pitchShiftUnit.pitch
        
        // Show the Pitch tab if the Effects panel is shown
        showThisTab()
    }
}

extension PitchShiftUnitProtocol {
    
    func increasePitchByOctave() -> PitchShift {
        increasePitch(by: .oneOctave, ensureActive: false)
    }
    
    func increasePitchBySemitone() -> PitchShift {
        increasePitch(by: .oneSemitone, ensureActive: false)
    }
    
    func increasePitchByCent() -> PitchShift {
        increasePitch(by: 1, ensureActive: false)
    }
    
    func decreasePitchByOctave() -> PitchShift {
        decreasePitch(by: .oneOctave, ensureActive: false)
    }
    
    func decreasePitchBySemitone() -> PitchShift {
        decreasePitch(by: .oneSemitone, ensureActive: false)
    }
    
    func decreasePitchByCent() -> PitchShift {
        decreasePitch(by: 1, ensureActive: false)
    }
}
