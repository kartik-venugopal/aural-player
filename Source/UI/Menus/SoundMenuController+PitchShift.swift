//
// SoundMenuController+PitchShift.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

extension SoundMenuController {
    
    func setUpPitchShiftMenu() {
        
        // Pitch shift menu items
        twoOctavesBelowMenuItem.paramValue = -2
        oneOctaveBelowMenuItem.paramValue = -1
        oneOctaveAboveMenuItem.paramValue = 1
        twoOctavesAboveMenuItem.paramValue = 2
    }
    
    // Decreases the pitch by a certain preset decrement
    @IBAction func decreasePitchAction(_ sender: Any) {
        
        pitchShiftUnit.decreasePitch()
        messenger.publish(.Effects.PitchShiftUnit.pitchUpdated)
    }
    
    // Increases the pitch by a certain preset increment
    @IBAction func increasePitchAction(_ sender: Any) {
        
        pitchShiftUnit.increasePitch()
        messenger.publish(.Effects.PitchShiftUnit.pitchUpdated)
    }
    
    // Sets the pitch to a value specified by the menu item clicked
    @IBAction func setPitchAction(_ sender: SoundParameterMenuItem) {
        
        // Menu item's "paramValue" specifies the pitch shift value associated with the menu item (in cents)
        let pitch = Int(sender.paramValue)
        
        pitchShiftUnit.pitch = PitchShift(octaves: pitch)
        pitchShiftUnit.ensureActive()
        messenger.publish(.Effects.PitchShiftUnit.pitchUpdated)
    }
}

extension PitchShiftUnitProtocol {
    
    fileprivate var pitchShiftDelta: Float {
        Float(preferences.soundPreferences.pitchDelta)
    }
    
    func decreasePitch() {
        decreasePitch(by: pitchShiftDelta, ensureActive: true)
    }
    
    func increasePitch() {
        increasePitch(by: pitchShiftDelta, ensureActive: true)
    }
}
