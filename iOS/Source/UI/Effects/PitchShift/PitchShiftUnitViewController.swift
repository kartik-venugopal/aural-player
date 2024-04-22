//
//  PitchShiftUnitViewController.swift
//  Aural-iOS
//
//  Created by Kartik Venugopal on 24/09/22.
//

import UIKit

class PitchShiftUnitViewController: UIViewController {
    
    @IBOutlet weak var btnBypass: UIButton!
    
    @IBOutlet weak var pitchSlider: UISlider!
    
    @IBOutlet weak var lblOctaves: UILabel!
    @IBOutlet weak var lblSemitones: UILabel!
    @IBOutlet weak var lblCents: UILabel!
    
    // MARK: Services, utilities, helpers, and properties

    var pitchShiftUnit: PitchShiftUnitDelegateProtocol = audioGraphDelegate.pitchShiftUnit
    
    ///
    /// Sets the state of the controls based on the current state of the FX unit.
    ///
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        navigationItem.title = "Pitch Shift Settings"
        
        btnBypass.tintColor = pitchShiftUnit.isActive ? .blue : .gray
        let pitch = pitchShiftUnit.pitch
        pitchSlider.value = pitch.asCentsFloat
        updateLabels(pitch: pitch)
    }
    
    private func updateLabels(pitch: PitchShift) {
        
        lblOctaves.text = "\(pitch.octaves.signedString)"
        lblSemitones.text = "\(pitch.semitones.signedString)"
        lblCents.text = "\(pitch.cents.signedString)"
    }

    // ------------------------------------------------------------------------

    // MARK: Actions

    // Activates/deactivates the Time stretch effects unit
    @IBAction func bypassAction(_ sender: UIButton) {
        
        _ = pitchShiftUnit.toggleState()
        btnBypass.tintColor = pitchShiftUnit.isActive ? .blue : .gray
    }

    // Updates the pitch
    @IBAction func pitchShiftAction(_ sender: AnyObject) {
        
        let newPitch = PitchShift(fromCents: pitchSlider.value)
        pitchShiftUnit.pitch = newPitch
        updateLabels(pitch: newPitch)
    }
    
    @IBAction func increasePitchByOctaveAction(_ sender: AnyObject) {
        
        let newPitch = pitchShiftUnit.increasePitchOneOctave()
        updateLabels(pitch: newPitch)
        pitchSlider.value = newPitch.asCentsFloat
    }
    
    @IBAction func increasePitchBySemitoneAction(_ sender: AnyObject) {
        
        let newPitch = pitchShiftUnit.increasePitchOneSemitone()
        updateLabels(pitch: newPitch)
        pitchSlider.value = newPitch.asCentsFloat
    }
    
    @IBAction func increasePitchByCentAction(_ sender: AnyObject) {
        
        let newPitch = pitchShiftUnit.increasePitchOneCent()
        updateLabels(pitch: newPitch)
        pitchSlider.value = newPitch.asCentsFloat
    }
    
    @IBAction func decreasePitchByOctaveAction(_ sender: AnyObject) {
        
        let newPitch = pitchShiftUnit.decreasePitchOneOctave()
        updateLabels(pitch: newPitch)
        pitchSlider.value = newPitch.asCentsFloat
    }
    
    @IBAction func decreasePitchBySemitoneAction(_ sender: AnyObject) {
        
        let newPitch = pitchShiftUnit.decreasePitchOneSemitone()
        updateLabels(pitch: newPitch)
        pitchSlider.value = newPitch.asCentsFloat
    }
    
    @IBAction func decreasePitchByCentAction(_ sender: AnyObject) {
        
        let newPitch = pitchShiftUnit.decreasePitchOneCent()
        updateLabels(pitch: newPitch)
        pitchSlider.value = newPitch.asCentsFloat
    }
}
