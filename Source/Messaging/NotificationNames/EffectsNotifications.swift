//
//  EffectsNotifications.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// Notifications pertaining to audio effects.
///
extension Notification.Name {
    
    // MARK: Notifications published by Effects (effects processing) components.
    
    // Signifies that an effects unit has just been activated
    static let effects_unitActivated = Notification.Name("effects_unitActivated")
    
    // Signifies that the bypass state of an effects unit has changed
    static let effects_unitStateChanged = Notification.Name("effects_unitStateChanged")
    
    // Signifies that the playback rate (of the time stretch effects unit) has changed.
    static let effects_playbackRateChanged = Notification.Name("effects_playbackRateChanged")
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Notifications published by the Audio Units effects unit.
    
    static let auEffectsUnit_audioUnitsAddedOrRemoved = Notification.Name("auEffectsUnit_audioUnitsAddedOrRemoved")
    
    // MARK: Effects commands
    
    // Commands the effects panel to switch the tab group to a specfic tab (to reveal a specific effects unit).
    static let effects_showEffectsUnitTab = Notification.Name("effects_showEffectsUnitTab")

    // Commands a particular effects unit to update its view
    static let effects_updateEffectsUnitView = Notification.Name("effects_updateEffectsUnitView")
    
    // Commands the audio graph to save the current sound settings (i.e. volume, pan, and effects) in a sound profile for the current track
    static let effects_saveSoundProfile = Notification.Name("effects_saveSoundProfile")

    // Commands the audio graph to delete the saved sound profile for the current track.
    static let effects_deleteSoundProfile = Notification.Name("effects_deleteSoundProfile")
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Master effects unit commands

    // Commands the Master effects unit to toggle (i.e. disable/enable) all effects.
    static let masterEffectsUnit_toggleEffects = Notification.Name("masterEffectsUnit_toggleEffects")

    // ----------------------------------------------------------------------------------------
    
    // MARK: EQ effects unit commands
    
    // Commands the Equalizer effects unit to decrease gain for each of the bass bands by a certain preset decrement
    static let eqEffectsUnit_decreaseBass = Notification.Name("eqEffectsUnit_decreaseBass")

    // Commands the Equalizer effects unit to provide a "bass boost", i.e. increase gain for each of the bass bands by a certain preset increment.
    static let eqEffectsUnit_increaseBass = Notification.Name("eqEffectsUnit_increaseBass")

    // Commands the Equalizer effects unit to decrease gain for each of the mid-frequency bands by a certain preset decrement
    static let eqEffectsUnit_decreaseMids = Notification.Name("eqEffectsUnit_decreaseMids")
    
    // Commands the Equalizer effects unit to increase gain for each of the mid-frequency bands by a certain preset increment
    static let eqEffectsUnit_increaseMids = Notification.Name("eqEffectsUnit_increaseMids")

    // Commands the Equalizer effects unit to decrease gain for each of the treble bands by a certain preset decrement
    static let eqEffectsUnit_decreaseTreble = Notification.Name("eqEffectsUnit_decreaseTreble")
    
    // Commands the Equalizer effects unit to increase gain for each of the treble bands by a certain preset increment
    static let eqEffectsUnit_increaseTreble = Notification.Name("eqEffectsUnit_increaseTreble")
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Pitch Shift effects unit commands
    
    // Commands the Pitch Shift effects unit to decrease the pitch by a certain preset decrement
    static let pitchEffectsUnit_decreasePitch = Notification.Name("pitchEffectsUnit_decreasePitch")

    // Commands the Pitch Shift effects unit to increase the pitch by a certain preset increment
    static let pitchEffectsUnit_increasePitch = Notification.Name("pitchEffectsUnit_increasePitch")

    // Commands the Pitch Shift effects unit to set the pitch to a specific value
    static let pitchEffectsUnit_setPitch = Notification.Name("pitchEffectsUnit_setPitch")
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Time Stretch effects unit commands
    
    // Commands the Time Stretch effects unit to decrease the playback rate by a certain preset decrement
    static let timeEffectsUnit_decreaseRate = Notification.Name("timeEffectsUnit_decreaseRate")

    // Commands the Time Stretch effects unit to increase the playback rate by a certain preset increment
    static let timeEffectsUnit_increaseRate = Notification.Name("timeEffectsUnit_increaseRate")

    // Commands the Time Stretch effects unit to set the playback rate to a specific value
    static let timeEffectsUnit_setRate = Notification.Name("timeEffectsUnit_setRate")
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Color scheme commands sent to the Effects UI
    
    // Commands all Effects views to change the text color of their function caption labels.
    static let effects_changeFunctionCaptionTextColor = Notification.Name("effects_changeFunctionCaptionTextColor")

    // Commands all Effects views to change the text color of their function value labels.
    static let effects_changeFunctionValueTextColor = Notification.Name("effects_changeFunctionValueTextColor")

    // Commands all Effects views to redraw their slider controls.
    static let effects_changeSliderColors = Notification.Name("effects_changeSliderColors")

    // Commands Effects views corresponding to "active" effects units, to redraw all their controls.
    static let effects_changeActiveUnitStateColor = Notification.Name("effects_changeActiveUnitStateColor")

    // Commands Effects views corresponding to "bypassed" effects units, to redraw all their controls.
    static let effects_changeBypassedUnitStateColor = Notification.Name("effects_changeBypassedUnitStateColor")

    // Commands Effects views corresponding to "suppressed" effects units, to redraw all their controls.
    static let effects_changeSuppressedUnitStateColor = Notification.Name("effects_changeSuppressedUnitStateColor")
}
