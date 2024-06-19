//
//  Preferences.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
/*
 Handles loading/saving of app user preferences
 */
import Foundation

///
/// Encapsulates all user preferences for this application.
///
class Preferences {
    
    /// The underlying datastore containing the user preferences.
    let defaults: UserDefaults
    
    // Preferences for different app components / features.
    
    var playQueuePreferences: PlayQueuePreferences
    var playbackPreferences: PlaybackPreferences
    var soundPreferences: SoundPreferences
    
#if os(macOS)
    var viewPreferences: ViewPreferences
#endif
    
    var historyPreferences: HistoryPreferences
    var controlsPreferences: ControlsPreferences
    var metadataPreferences: MetadataPreferences
    
    init(defaults: UserDefaults, needToMigrateLegacySettings: Bool) {
        
        self.defaults = defaults
        
        lazy var dict = defaults.dictionaryRepresentation()
        
        playQueuePreferences = PlayQueuePreferences(legacyPreferences: needToMigrateLegacySettings ? LegacyPlaylistPreferences.init(dict) : nil)
        controlsPreferences = ControlsPreferences(legacyPreferences: needToMigrateLegacySettings ? LegacyControlsPreferences.init(dict) : nil)
        playbackPreferences = PlaybackPreferences(controlsPreferences: controlsPreferences.gestures)
        soundPreferences = SoundPreferences(controlsPreferences: controlsPreferences.gestures,
                                            legacyPreferences: needToMigrateLegacySettings ? LegacySoundPreferences.init(dict) : nil)
        
#if os(macOS)
        viewPreferences = ViewPreferences()
#endif
        
        historyPreferences = HistoryPreferences(legacyPreferences: needToMigrateLegacySettings ? LegacyHistoryPreferences() : nil)
        metadataPreferences = MetadataPreferences()
    }
}
