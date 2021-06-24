//
//  TimeUnitDelegate.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

class TimeUnitDelegate: FXUnitDelegate<TimeUnit>, TimeUnitDelegateProtocol {
    
    let preferences: SoundPreferences
    
    var rate: Float {
        
        get {unit.rate}
        set {unit.rate = newValue}
    }
    
    var effectiveRate: Float {
        return isActive ? rate : 1.0
    }
    
    var formattedRate: String {return ValueFormatter.formatTimeStretchRate(rate)}
    
    var overlap: Float {
        
        get {unit.overlap}
        set {unit.overlap = newValue}
    }
    
    var formattedOverlap: String {return ValueFormatter.formatOverlap(overlap)}
    
    var shiftPitch: Bool {
        
        get {unit.shiftPitch}
        set {unit.shiftPitch = newValue}
    }
    
    var pitch: Float {return unit.pitch}
    
    var formattedPitch: String {return ValueFormatter.formatPitch(pitch * ValueConversions.pitch_audioGraphToUI)}
    
    var presets: TimePresets {return unit.presets}
    
    init(_ unit: TimeUnit, _ preferences: SoundPreferences) {
        
        self.preferences = preferences
        super.init(unit)
    }
    
    func increaseRate() -> (rate: Float, rateString: String) {
        
        ensureActiveAndResetRate()
        
        // Rate is increased by an amount set in the user preferences
        // TODO: Put this value in a constant
        rate = min(4, rate + preferences.timeDelta)
        
        return (rate, formattedRate)
    }
    
    func decreaseRate() -> (rate: Float, rateString: String) {
        
        ensureActiveAndResetRate()
        
        // Rate is decreased by an amount set in the user preferences
        // TODO: Put this value in a constant
        rate = max(0.25, rate - preferences.timeDelta)
        
        return (rate, formattedRate)
    }
    
    private func ensureActiveAndResetRate() {
        
        if state != .active {
            
            _ = toggleState()
            
            // If the time unit is currently inactive, start at default playback rate, before the increase
            rate = AudioGraphDefaults.timeStretchRate
        }
    }
}
