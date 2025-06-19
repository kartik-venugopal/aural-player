//
// SoundMenuController+TimeStretch.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

extension SoundMenuController {
    
    func setUpTimeStretchMenu() {
        
        // Playback rate (Time) menu items
        rate0_25MenuItem.paramValue = 0.25
        rate0_5MenuItem.paramValue = 0.5
        rate0_75MenuItem.paramValue = 0.75
        rate1_25MenuItem.paramValue = 1.25
        rate1_5MenuItem.paramValue = 1.5
        rate2MenuItem.paramValue = 2
        rate3MenuItem.paramValue = 3
        rate4MenuItem.paramValue = 4
    }
    
    // Decreases the playback rate by a certain preset decrement
    @IBAction func decreaseRateAction(_ sender: Any) {
        
        timeStretchUnit.decreaseRate()
        messenger.publish(.Effects.TimeStretchUnit.rateUpdated)
    }
    
    // Increases the playback rate by a certain preset increment
    @IBAction func increaseRateAction(_ sender: Any) {
        
        timeStretchUnit.increaseRate()
        messenger.publish(.Effects.TimeStretchUnit.rateUpdated)
    }
    
    // Sets the playback rate to a value specified by the menu item clicked
    @IBAction func setRateAction(_ sender: SoundParameterMenuItem) {
        
        // Menu item's "paramValue" specifies the playback rate value associated with the menu item
        let rate = sender.paramValue
        timeStretchUnit.rate = rate
        timeStretchUnit.ensureActive()
        messenger.publish(.Effects.TimeStretchUnit.rateUpdated)
    }
}

extension TimeStretchUnitProtocol {
    
    fileprivate var rateDelta: Float {
        preferences.soundPreferences.timeStretchDelta
    }
    
    func increaseRate() {
        increaseRate(by: rateDelta, ensureActive: true)
    }
    
    func decreaseRate() {
        decreaseRate(by: rateDelta, ensureActive: true)
    }
}
