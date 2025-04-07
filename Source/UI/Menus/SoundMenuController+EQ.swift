//
// SoundMenuController+EQ.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

extension SoundMenuController {
    
    // Decreases each of the EQ bass bands by a certain preset decrement
    @IBAction func decreaseBassAction(_ sender: Any) {
        
        eqUnit.decreaseBass()
        messenger.publish(.Effects.EQUnit.bandsUpdated)
    }
    
    // Provides a "bass boost". Increases each of the EQ bass bands by a certain preset increment.
    @IBAction func increaseBassAction(_ sender: Any) {
        
        eqUnit.increaseBass()
        messenger.publish(.Effects.EQUnit.bandsUpdated)
    }
    
    // Decreases each of the EQ mid-frequency bands by a certain preset decrement
    @IBAction func decreaseMidsAction(_ sender: Any) {
        
        eqUnit.decreaseMids()
        messenger.publish(.Effects.EQUnit.bandsUpdated)
    }
    
    // Increases each of the EQ mid-frequency bands by a certain preset increment
    @IBAction func increaseMidsAction(_ sender: Any) {
        
        eqUnit.increaseMids()
        messenger.publish(.Effects.EQUnit.bandsUpdated)
    }
    
    // Decreases each of the EQ treble bands by a certain preset decrement
    @IBAction func decreaseTrebleAction(_ sender: Any) {
        
        eqUnit.decreaseTreble()
        messenger.publish(.Effects.EQUnit.bandsUpdated)
    }
    
    // Decreases each of the EQ treble bands by a certain preset increment
    @IBAction func increaseTrebleAction(_ sender: Any) {
        
        eqUnit.increaseTreble()
        messenger.publish(.Effects.EQUnit.bandsUpdated)
    }
}

extension EQUnitProtocol {
    
    fileprivate var eqDelta: Float {
        preferences.soundPreferences.eqDelta
    }
    
    func increaseBass() {
        increaseBass(by: eqDelta)
    }

    func decreaseBass() {
        decreaseBass(by: eqDelta)
    }
    
    func increaseMids() {
        increaseMids(by: eqDelta)
    }
    
    func decreaseMids() {
        decreaseMids(by: eqDelta)
    }
    
    func increaseTreble() {
        increaseTreble(by: eqDelta)
    }
    
    func decreaseTreble() {
        decreaseTreble(by: eqDelta)
    }
}
