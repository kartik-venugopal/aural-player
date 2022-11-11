//
//  MediaKeysControlsPreferencesTests.swift
//  Tests
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class MediaKeysControlsPreferencesTests: PreferencesTestCase {
    
    private typealias Defaults = PreferencesDefaults.Controls.MediaKeys
    
    // MARK: init() tests ------------------------------
    
    func testInit_noValues() {
        
        doTestInit(userDefs: UserDefaults(),
                   enabled: nil,
                   skipKeyBehavior: nil,
                   repeatSpeed: nil)
    }
    
    func testInit_someValues() {
        
        for _ in 1...(runLongRunningTests ? 1000 : 100) {
            
            doTestInit(userDefs: UserDefaults(),
                       enabled: randomNillableBool(),
                       skipKeyBehavior: randomNillableSkipKeyBehavior(),
                       repeatSpeed: randomNillableRepeatSpeed())
            
        }
    }
    
    func testInit() {
        
        for _ in 1...(runLongRunningTests ? 1000 : 100) {
            
            doTestInit(userDefs: UserDefaults(),
                       enabled: .random(),
                       skipKeyBehavior: randomSkipKeyBehavior(),
                       repeatSpeed: randomRepeatSpeed())
        }
    }
    
    private func doTestInit(userDefs: UserDefaults,
                            enabled: Bool?,
                            skipKeyBehavior: SkipKeyBehavior?,
                            repeatSpeed: SkipKeyRepeatSpeed?) {
        
        userDefs[MediaKeysControlsPreferences.key_enabled] = enabled
        userDefs[MediaKeysControlsPreferences.key_skipKeyBehavior] = skipKeyBehavior?.rawValue
        userDefs[MediaKeysControlsPreferences.key_repeatSpeed] = repeatSpeed?.rawValue
        
        let prefs = MediaKeysControlsPreferences(userDefs.dictionaryRepresentation())
        
        XCTAssertEqual(prefs.enabled, enabled ?? Defaults.enabled)
        XCTAssertEqual(prefs.skipKeyBehavior, skipKeyBehavior ?? Defaults.skipKeyBehavior)
        XCTAssertEqual(prefs.repeatSpeed, repeatSpeed ?? Defaults.repeatSpeed)
    }
    
    // MARK: persist() tests ------------------------------
    
    func testPersist() {
        
        for _ in 1...(runLongRunningTests ? 1000 : 100) {
            doTestPersist(prefs: randomMediaKeysPreferences())
        }
    }
    
    func testPersist_serializeAndDeserialize() {
        
        for _ in 1...(runLongRunningTests ? 1000 : 100) {
            
            let defaults = UserDefaults()
            let serializedPrefs = randomMediaKeysPreferences()
            doTestPersist(prefs: serializedPrefs, userDefs: defaults)
            
            let deserializedPrefs = MediaKeysControlsPreferences(UserDefaults.standard.dictionaryRepresentation())
            compare(prefs: deserializedPrefs, userDefs: defaults)
        }
    }
    
    private func doTestPersist(prefs: MediaKeysControlsPreferences) {
        doTestPersist(prefs: prefs, userDefs: UserDefaults())
    }
    
    private func doTestPersist(prefs: MediaKeysControlsPreferences, userDefs: UserDefaults) {
        
        prefs.persist(to: userDefs)
        compare(prefs: prefs, userDefs: userDefs)
    }
}
