//
//  RemoteControlPreferencesTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class RemoteControlPreferencesTests: PreferencesTestCase {
    
    private typealias Defaults = PreferencesDefaults.Controls.RemoteControl
    
    // MARK: init() tests ------------------------------
    
    func testInit_noValues() {
        
        doTestInit(userDefs: UserDefaults(),
                   enabled: nil,
                   trackChangeOrSeekingOption: nil)
    }
    
    func testInit_someValues() {
        
        for _ in 1...(runLongRunningTests ? 1000 : 100) {
            
            doTestInit(userDefs: UserDefaults(),
                       enabled: randomNillableBool(),
                       trackChangeOrSeekingOption: randomNillableTrackChangeOrSeekingOption())
            
        }
    }
    
    func testInit() {
        
        for _ in 1...(runLongRunningTests ? 1000 : 100) {
            
            doTestInit(userDefs: UserDefaults(),
                       enabled: .random(),
                       trackChangeOrSeekingOption: randomTrackChangeOrSeekingOption())
        }
    }
    
    private func doTestInit(userDefs: UserDefaults,
                            enabled: Bool?,
                            trackChangeOrSeekingOption: TrackChangeOrSeekingOptions?) {
        
        userDefs[RemoteControlPreferences.key_enabled] = enabled
        userDefs[RemoteControlPreferences.key_trackChangeOrSeekingOption] = trackChangeOrSeekingOption?.rawValue
        
        let prefs = RemoteControlPreferences(userDefs.dictionaryRepresentation())
        
        XCTAssertEqual(prefs.enabled, enabled ?? Defaults.enabled)
        XCTAssertEqual(prefs.trackChangeOrSeekingOption, trackChangeOrSeekingOption ?? Defaults.trackChangeOrSeekingOption)
    }
    
    // MARK: persist() tests ------------------------------
    
    func testPersist() {
        
        for _ in 1...(runLongRunningTests ? 1000 : 100) {
            doTestPersist(prefs: randomRemoteControlPreferences())
        }
    }
    
    func testPersist_serializeAndDeserialize() {
        
        for _ in 1...(runLongRunningTests ? 1000 : 100) {
            
            let defaults = UserDefaults()
            let serializedPrefs = randomRemoteControlPreferences()
            doTestPersist(prefs: serializedPrefs, userDefs: defaults)
            
            let deserializedPrefs = RemoteControlPreferences(UserDefaults.standard.dictionaryRepresentation())
            compare(prefs: deserializedPrefs, userDefs: defaults)
        }
    }
    
    private func doTestPersist(prefs: RemoteControlPreferences) {
        doTestPersist(prefs: prefs, userDefs: UserDefaults())
    }
    
    private func doTestPersist(prefs: RemoteControlPreferences, userDefs: UserDefaults) {
        
        prefs.persist(to: userDefs)
        compare(prefs: prefs, userDefs: userDefs)
    }
}
