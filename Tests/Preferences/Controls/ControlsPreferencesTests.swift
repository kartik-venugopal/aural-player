//
//  ControlsPreferencesTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class ControlsPreferencesTests: PreferencesTestCase {
    
    private typealias MediaKeysDefaults = PreferencesDefaults.Controls.MediaKeys
    private typealias GesturesDefaults = PreferencesDefaults.Controls.Gestures
    private typealias RemoteControlDefaults = PreferencesDefaults.Controls.RemoteControl
    
    // MARK: init() tests ------------------------------
    
    func testInit_noValues() {
        
        doTestInit(userDefs: UserDefaults(),
                   mediaKeysEnabled: nil,
                   skipKeyBehavior: nil,
                   repeatSpeed: nil,
                   allowVolumeControl: nil,
                   allowSeeking: nil,
                   allowTrackChange: nil,
                   allowPlaylistNavigation: nil,
                   allowPlaylistTabToggle: nil,
                   volumeControlSensitivity: nil,
                   seekSensitivity: nil,
                   remoteControlEnabled: nil,
                   trackChangeOrSeekingOption: nil)
    }
    
    func testInit() {
        
        for _ in 1...100 {
            
            doTestInit(userDefs: UserDefaults(),
                       mediaKeysEnabled: .random(),
                       skipKeyBehavior: randomSkipKeyBehavior(),
                       repeatSpeed: randomRepeatSpeed(),
                       allowVolumeControl: .random(),
                       allowSeeking: .random(),
                       allowTrackChange: .random(),
                       allowPlaylistNavigation: .random(),
                       allowPlaylistTabToggle: .random(),
                       volumeControlSensitivity: .randomCase(),
                       seekSensitivity: .randomCase(),
                       remoteControlEnabled: .random(),
                       trackChangeOrSeekingOption: randomTrackChangeOrSeekingOption())
        }
    }
    
    private func doTestInit(userDefs: UserDefaults,
                            mediaKeysEnabled: Bool?,
                            skipKeyBehavior: SkipKeyBehavior?,
                            repeatSpeed: SkipKeyRepeatSpeed?,
                            allowVolumeControl: Bool?,
                            allowSeeking: Bool?,
                            allowTrackChange: Bool?,
                            allowPlaylistNavigation: Bool?,
                            allowPlaylistTabToggle: Bool?,
                            volumeControlSensitivity: ScrollSensitivity?,
                            seekSensitivity: ScrollSensitivity?,
                            remoteControlEnabled: Bool?,
                            trackChangeOrSeekingOption: TrackChangeOrSeekingOptions?) {
        
        userDefs[MediaKeysControlsPreferences.key_enabled] = mediaKeysEnabled
        userDefs[MediaKeysControlsPreferences.key_skipKeyBehavior] = skipKeyBehavior?.rawValue
        userDefs[MediaKeysControlsPreferences.key_repeatSpeed] = repeatSpeed?.rawValue
        
        userDefs[GesturesControlsPreferences.key_allowPlaylistNavigation] = allowPlaylistNavigation
        userDefs[GesturesControlsPreferences.key_allowPlaylistTabToggle] = allowPlaylistTabToggle
        
        userDefs[GesturesControlsPreferences.key_allowSeeking] = allowSeeking
        userDefs[GesturesControlsPreferences.key_allowTrackChange] = allowTrackChange
        userDefs[GesturesControlsPreferences.key_allowVolumeControl] = allowVolumeControl
        
        userDefs[GesturesControlsPreferences.key_seekSensitivity] = seekSensitivity?.rawValue
        userDefs[GesturesControlsPreferences.key_volumeControlSensitivity] = volumeControlSensitivity?.rawValue
        
        userDefs[RemoteControlPreferences.key_enabled] = remoteControlEnabled
        userDefs[RemoteControlPreferences.key_trackChangeOrSeekingOption] = trackChangeOrSeekingOption?.rawValue
        
        let prefs = ControlsPreferences(userDefs.dictionaryRepresentation())
        
        XCTAssertEqual(prefs.mediaKeys.enabled,
                       mediaKeysEnabled ?? MediaKeysDefaults.enabled)
        
        XCTAssertEqual(prefs.mediaKeys.skipKeyBehavior,
                       skipKeyBehavior ?? MediaKeysDefaults.skipKeyBehavior)
        
        XCTAssertEqual(prefs.mediaKeys.repeatSpeed,
                       repeatSpeed ?? MediaKeysDefaults.repeatSpeed)
        
        XCTAssertEqual(prefs.gestures.allowPlaylistNavigation,
                       allowPlaylistNavigation ?? GesturesDefaults.allowPlaylistNavigation)
        
        XCTAssertEqual(prefs.gestures.allowPlaylistTabToggle,
                       allowPlaylistTabToggle ?? GesturesDefaults.allowPlaylistTabToggle)
        
        XCTAssertEqual(prefs.gestures.allowSeeking,
                       allowSeeking ?? GesturesDefaults.allowSeeking)
        
        XCTAssertEqual(prefs.gestures.allowTrackChange,
                       allowTrackChange ?? GesturesDefaults.allowTrackChange)
        
        XCTAssertEqual(prefs.gestures.allowVolumeControl,
                       allowVolumeControl ?? GesturesDefaults.allowVolumeControl)
        
        XCTAssertEqual(prefs.gestures.seekSensitivity,
                       seekSensitivity ?? GesturesDefaults.seekSensitivity)
        
        XCTAssertEqual(prefs.gestures.volumeControlSensitivity,
                       volumeControlSensitivity ?? GesturesDefaults.volumeControlSensitivity)
        
        XCTAssertEqual(prefs.remoteControl.enabled,
                       remoteControlEnabled ?? RemoteControlDefaults.enabled)
        
        XCTAssertEqual(prefs.remoteControl.trackChangeOrSeekingOption,
                       trackChangeOrSeekingOption ?? RemoteControlDefaults.trackChangeOrSeekingOption)
    }
    
    // MARK: persist() tests ------------------------------
    
    func testPersist() {
        
        for _ in 1...100 {
            doTestPersist(prefs: randomControlsPreferences())
        }
    }
    
    func testPersist_serializeAndDeserialize() {
        
        for _ in 1...100 {
            
            let defaults = UserDefaults()
            let serializedPrefs = randomControlsPreferences()
            doTestPersist(prefs: serializedPrefs, userDefs: defaults)
            
            let deserializedPrefs = ControlsPreferences(UserDefaults.standard.dictionaryRepresentation())
            compare(prefs: deserializedPrefs, userDefs: defaults)
        }
    }
    
    private func doTestPersist(prefs: ControlsPreferences) {
        doTestPersist(prefs: prefs, userDefs: UserDefaults())
    }
    
    private func doTestPersist(prefs: ControlsPreferences, userDefs: UserDefaults) {
        
        prefs.persist(to: userDefs)
        compare(prefs: prefs, userDefs: userDefs)
    }
}
