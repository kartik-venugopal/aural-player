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

class RemoteControlPreferencesTests: AuralTestCase {
    
    private typealias Defaults = PreferencesDefaults.Controls.RemoteControl
    
    // MARK: init() tests ------------------------------
    
    func testInit_noValues() {
        
        doTestInit(userDefs: UserDefaults(),
                   enabled: nil,
                   trackChangeOrSeekingOption: nil)
    }
    
    func testInit_someValues() {
        
        for _ in 1...100 {
            
            doTestInit(userDefs: UserDefaults(),
                       enabled: randomNillableBool(),
                       trackChangeOrSeekingOption: randomNillableTrackChangeOrSeekingOption())
            
        }
    }
    
    func testInit() {
        
        for _ in 1...100 {
            
            doTestInit(userDefs: UserDefaults(),
                       enabled: Bool.random(),
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
        
        for _ in 1...100 {
            doTestPersist(prefs: randomPreferences())
        }
    }
    
    func testPersist_serializeAndDeserialize() {
        
        for _ in 1...100 {
            
            let serializedPrefs = randomPreferences()
            doTestPersist(prefs: serializedPrefs, userDefs: UserDefaults.standard)
            
            let deserializedPrefs = RemoteControlPreferences(UserDefaults.standard.dictionaryRepresentation())
            compare(prefs: deserializedPrefs, userDefs: UserDefaults.standard)
        }
    }
    
    private func doTestPersist(prefs: RemoteControlPreferences) {
        doTestPersist(prefs: prefs, userDefs: UserDefaults())
    }
    
    private func doTestPersist(prefs: RemoteControlPreferences, userDefs: UserDefaults) {
        
        prefs.persist(to: userDefs)
        compare(prefs: prefs, userDefs: userDefs)
    }
    
    private func compare(prefs: RemoteControlPreferences, userDefs: UserDefaults) {
        
        XCTAssertEqual(userDefs.bool(forKey: RemoteControlPreferences.key_enabled), prefs.enabled)
        XCTAssertEqual(userDefs.string(forKey: RemoteControlPreferences.key_trackChangeOrSeekingOption), prefs.trackChangeOrSeekingOption.rawValue)
    }
    
    // MARK: Helper functions ------------------------------
    
    private func randomPreferences() -> RemoteControlPreferences {
        
        let prefs = RemoteControlPreferences([:])
        
        prefs.enabled = Bool.random()
        prefs.trackChangeOrSeekingOption = randomTrackChangeOrSeekingOption()
        
        return prefs
    }
    
    private func randomTrackChangeOrSeekingOption() -> TrackChangeOrSeekingOptions {TrackChangeOrSeekingOptions.randomCase()}
    
    private func randomNillableTrackChangeOrSeekingOption() -> TrackChangeOrSeekingOptions? {
        randomNillableValue {self.randomTrackChangeOrSeekingOption()}
    }
}
