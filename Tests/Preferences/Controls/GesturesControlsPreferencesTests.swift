//
//  GesturesControlsPreferencesTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class GesturesControlsPreferencesTests: PreferencesTestCase {
    
    private typealias Defaults = PreferencesDefaults.Controls.Gestures
    
    // MARK: init() tests ------------------------------
    
    func testInit_noValues() {
        
        doTestInit(userDefs: UserDefaults(),
                   allowVolumeControl: nil,
                   allowSeeking: nil,
                   allowTrackChange: nil,
                   allowPlaylistNavigation: nil,
                   allowPlaylistTabToggle: nil,
                   volumeControlSensitivity: nil,
                   seekSensitivity: nil)
    }
    
    func testInit_someValues() {
        
        for _ in 1...(runLongRunningTests ? 1000 : 100) {
            
            doTestInit(userDefs: UserDefaults(),
                       allowVolumeControl: randomNillableBool(),
                       allowSeeking: randomNillableBool(),
                       allowTrackChange: randomNillableBool(),
                       allowPlaylistNavigation: randomNillableBool(),
                       allowPlaylistTabToggle: randomNillableBool(),
                       volumeControlSensitivity: randomNillableScrollSensitivity(),
                       seekSensitivity: randomNillableScrollSensitivity())
        }
    }
    
    func testInit() {
        
        for _ in 1...(runLongRunningTests ? 1000 : 100) {
            
            doTestInit(userDefs: UserDefaults(),
                       allowVolumeControl: .random(),
                       allowSeeking: .random(),
                       allowTrackChange: .random(),
                       allowPlaylistNavigation: .random(),
                       allowPlaylistTabToggle: .random(),
                       volumeControlSensitivity: .randomCase(),
                       seekSensitivity: .randomCase())
        }
    }
    
    private func doTestInit(userDefs: UserDefaults,
                            allowVolumeControl: Bool?,
                            allowSeeking: Bool?,
                            allowTrackChange: Bool?,
                            allowPlaylistNavigation: Bool?,
                            allowPlaylistTabToggle: Bool?,
                            volumeControlSensitivity: ScrollSensitivity?,
                            seekSensitivity: ScrollSensitivity?) {
        
        userDefs[GesturesControlsPreferences.key_allowPlaylistNavigation] = allowPlaylistNavigation
        userDefs[GesturesControlsPreferences.key_allowPlaylistTabToggle] = allowPlaylistTabToggle
        
        userDefs[GesturesControlsPreferences.key_allowSeeking] = allowSeeking
        userDefs[GesturesControlsPreferences.key_allowTrackChange] = allowTrackChange
        userDefs[GesturesControlsPreferences.key_allowVolumeControl] = allowVolumeControl
        
        userDefs[GesturesControlsPreferences.key_seekSensitivity] = seekSensitivity?.rawValue
        userDefs[GesturesControlsPreferences.key_volumeControlSensitivity] = volumeControlSensitivity?.rawValue
        
        let prefs = GesturesControlsPreferences(userDefs.dictionaryRepresentation())

        XCTAssertEqual(prefs.allowPlaylistNavigation, allowPlaylistNavigation ?? Defaults.allowPlaylistNavigation)
        XCTAssertEqual(prefs.allowPlaylistTabToggle, allowPlaylistTabToggle ?? Defaults.allowPlaylistTabToggle)
        
        XCTAssertEqual(prefs.allowSeeking, allowSeeking ?? Defaults.allowSeeking)
        XCTAssertEqual(prefs.allowTrackChange, allowTrackChange ?? Defaults.allowTrackChange)
        XCTAssertEqual(prefs.allowVolumeControl, allowVolumeControl ?? Defaults.allowVolumeControl)
        
        XCTAssertEqual(prefs.seekSensitivity, seekSensitivity ?? Defaults.seekSensitivity)
        XCTAssertEqual(prefs.volumeControlSensitivity, volumeControlSensitivity ?? Defaults.volumeControlSensitivity)
    }
    
    // MARK: persist() tests ------------------------------
    
    func testPersist() {
        
        for _ in 1...(runLongRunningTests ? 1000 : 100) {
            doTestPersist(prefs: randomGesturesPreferences())
        }
    }
    
    func testPersist_serializeAndDeserialize() {
        
        for _ in 1...(runLongRunningTests ? 1000 : 100) {
            
            let defaults = UserDefaults()
            let serializedPrefs = randomGesturesPreferences()
            doTestPersist(prefs: serializedPrefs, userDefs: defaults)
            
            let deserializedPrefs = GesturesControlsPreferences(UserDefaults.standard.dictionaryRepresentation())
            compare(prefs: deserializedPrefs, userDefs: defaults)
        }
    }
    
    private func doTestPersist(prefs: GesturesControlsPreferences) {
        doTestPersist(prefs: prefs, userDefs: UserDefaults())
    }
    
    private func doTestPersist(prefs: GesturesControlsPreferences, userDefs: UserDefaults) {
        
        prefs.persist(to: userDefs)
        compare(prefs: prefs, userDefs: userDefs)
    }
}
