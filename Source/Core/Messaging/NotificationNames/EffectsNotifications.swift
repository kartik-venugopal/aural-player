//
//  EffectsNotifications.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Notifications pertaining to audio effects.
///
extension Notification.Name {
    
    struct Effects {
        
        // MARK: Notifications published by Effects (effects processing) components.
        
        static let sheetDismissed = Notification.Name("effects_sheetDismissed")
        
        // Signifies that an effects unit has just been activated
        static let unitActivated = Notification.Name("effects_unitActivated")
        
        // Signifies that the bypass state of an effects unit has changed
        static let unitStateChanged = Notification.Name("effects_unitStateChanged")
        
        static let auStateChanged = Notification.Name("effects_auStateChanged")
        
        // Signifies that the playback rate (of the time stretch effects unit) has changed.
        static let playbackRateChanged = Notification.Name("effects_playbackRateChanged")
        
        // ----------------------------------------------------------------------------------------
        
        // MARK: Notifications published by the Audio Units effects unit.
        
        static let audioUnitAdded = Notification.Name("effects_audioUnitAdded")
        static let audioUnitsRemoved = Notification.Name("effects_audioUnitsRemoved")

        // MARK: Effects commands
        
        // Commands the effects panel to switch the tab group to a specfic tab (to reveal a specific effects unit).
        static let showEffectsUnitTab = Notification.Name("effects_showEffectsUnitTab")
        
        // Commands a particular effects unit to update its view
        static let updateEffectsUnitView = Notification.Name("effects_updateEffectsUnitView")
        
        // Commands the audio graph to save the current sound settings (i.e. volume, pan, and effects) in a sound profile for the current track
        static let saveSoundProfile = Notification.Name("effects_saveSoundProfile")
        
        // Commands the audio graph to delete the saved sound profile for the current track.
        static let deleteSoundProfile = Notification.Name("effects_deleteSoundProfile")
        
        static let showPresetsAndSettingsMenu = Notification.Name("effects_showPresetsAndSettingsMenu")
        
        static let hidePresetsAndSettingsMenu = Notification.Name("effects_hidePresetsAndSettingsMenu")
        
        // ----------------------------------------------------------------------------------------
        
        // MARK: Master effects unit commands
        
        struct MasterUnit {
            
            // Commands the Master effects unit to toggle (i.e. disable/enable) all effects.
            static let toggleEffects = Notification.Name("effects_masterUnit_toggleEffects")
        }
        
        // ----------------------------------------------------------------------------------------
        
        // MARK: EQ effects unit commands
        
        struct EQUnit {
            
            // Commands the Equalizer effects unit to decrease gain for each of the bass bands by a certain preset decrement
            static let decreaseBass = Notification.Name("effects_eqUnit_decreaseBass")
            
            // Commands the Equalizer effects unit to provide a "bass boost", i.e. increase gain for each of the bass bands by a certain preset increment.
            static let increaseBass = Notification.Name("effects_eqUnit_increaseBass")
            
            // Commands the Equalizer effects unit to decrease gain for each of the mid-frequency bands by a certain preset decrement
            static let decreaseMids = Notification.Name("effects_eqUnit_decreaseMids")
            
            // Commands the Equalizer effects unit to increase gain for each of the mid-frequency bands by a certain preset increment
            static let increaseMids = Notification.Name("effects_eqUnit_increaseMids")
            
            // Commands the Equalizer effects unit to decrease gain for each of the treble bands by a certain preset decrement
            static let decreaseTreble = Notification.Name("effects_eqUnit_decreaseTreble")
            
            // Commands the Equalizer effects unit to increase gain for each of the treble bands by a certain preset increment
            static let increaseTreble = Notification.Name("effects_eqUnit_increaseTreble")
        }
        
        // ----------------------------------------------------------------------------------------
        
        struct PitchShiftUnit {
            
            // MARK: Pitch Shift effects unit commands
            
            // Commands the Pitch Shift effects unit to decrease the pitch by a certain preset decrement
            static let decreasePitch = Notification.Name("effects_pitchShiftUnit_decreasePitch")
            
            // Commands the Pitch Shift effects unit to increase the pitch by a certain preset increment
            static let increasePitch = Notification.Name("effects_pitchShiftUnit_increasePitch")
            
            // Commands the Pitch Shift effects unit to set the pitch to a specific value
            static let setPitch = Notification.Name("effects_pitchShiftUnit_setPitch")
        }
        
        // ----------------------------------------------------------------------------------------
        
        struct TimeStretchUnit {
            
            // MARK: Time Stretch effects unit commands
            
            // Commands the Time Stretch effects unit to decrease the playback rate by a certain preset decrement
            static let decreaseRate = Notification.Name("effects_timeStretchUnit_decreaseRate")
            
            // Commands the Time Stretch effects unit to increase the playback rate by a certain preset increment
            static let increaseRate = Notification.Name("effects_timeStretchUnit_increaseRate")
            
            // Commands the Time Stretch effects unit to set the playback rate to a specific value
            static let setRate = Notification.Name("effects_timeStretchUnit_setRate")
        }
        
        // ----------------------------------------------------------------------------------------
        
        struct FilterUnit {
            
            // MARK: Filter effects unit notifications
            
            // Notifies the filter unit that one of its bands has been updated. Payload includes the band index.
            static let bandUpdated = Notification.Name("effects_filterUnit_bandUpdated")
            
            // Notifies the filter unit that one of its bands' bypass state has been updated. Payload includes the band index.
            static let bandBypassStateUpdated = Notification.Name("effects_filterUnit_bandBypassStateUpdated")
        }
    }
}
