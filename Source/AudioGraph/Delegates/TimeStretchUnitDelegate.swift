//
//  TimeStretchUnitDelegate.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A delegate representing the Time Stretch effects unit.
///
/// Acts as a middleman between the Effects UI and the Time Stretch effects unit,
/// providing a simplified interface / facade for the UI layer to control the Time Stretch effects unit.
///
/// - SeeAlso: `TimeStretchUnit`
/// - SeeAlso: `TimeStretchUnitDelegateProtocol`
///
class TimeStretchUnitDelegate: EffectsUnitDelegate<TimeStretchUnit>, TimeStretchUnitDelegateProtocol {
    
    let preferences: SoundPreferences
    
    var rate: Float {
        
        get {unit.rate}
        
        // FIXME: Should call ensureActive() when setting rate ?
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
    
    var presets: TimeStretchPresets {return unit.presets}
    
    init(_ unit: TimeStretchUnit, _ preferences: SoundPreferences) {
        
        self.preferences = preferences
        super.init(unit)
    }
    
    func increaseRate() -> (rate: Float, rateString: String) {
        
        ensureActiveAndResetRate()
        
        // Rate is increased by an amount set in the user preferences
        rate = min(TimeStretchUnit.maxRate, rate + preferences.timeDelta)
        
        return (rate, formattedRate)
    }
    
    func decreaseRate() -> (rate: Float, rateString: String) {
        
        ensureActiveAndResetRate()
        
        // Rate is decreased by an amount set in the user preferences
        rate = max(TimeStretchUnit.minRate, rate - preferences.timeDelta)
        
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
