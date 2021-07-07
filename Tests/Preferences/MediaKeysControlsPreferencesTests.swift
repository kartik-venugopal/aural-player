//
//  MediaKeysControlsPreferencesTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
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
        
        for _ in 1...100 {
            
            resetDefaults()
            
            doTestInit(userDefs: UserDefaults(),
                       enabled: randomNillableBool(),
                       skipKeyBehavior: randomNillableSkipKeyBehavior(),
                       repeatSpeed: randomNillableRepeatSpeed())
            
        }
    }
    
    func testInit() {
        
        for _ in 1...100 {
            
            resetDefaults()
            
            doTestInit(userDefs: UserDefaults(),
                       enabled: Bool.random(),
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
        
        for _ in 1...100 {
            
            resetDefaults()
            doTestPersist(prefs: randomPreferences())
        }
    }
    
    func testPersist_serializeAndDeserialize() {
        
        for _ in 1...100 {
            
            resetDefaults()
            
            let serializedPrefs = randomPreferences()
            doTestPersist(prefs: serializedPrefs, userDefs: UserDefaults.standard)
            
            let deserializedPrefs = MediaKeysControlsPreferences(UserDefaults.standard.dictionaryRepresentation())
            compare(prefs: deserializedPrefs, userDefs: UserDefaults.standard)
        }
    }
    
    private func doTestPersist(prefs: MediaKeysControlsPreferences) {
        doTestPersist(prefs: prefs, userDefs: UserDefaults())
    }
    
    private func doTestPersist(prefs: MediaKeysControlsPreferences, userDefs: UserDefaults) {
        
        prefs.persist(to: userDefs)
        compare(prefs: prefs, userDefs: userDefs)
    }
    
    private func compare(prefs: MediaKeysControlsPreferences, userDefs: UserDefaults) {
        
        XCTAssertEqual(userDefs.bool(forKey: MediaKeysControlsPreferences.key_enabled), prefs.enabled)
        XCTAssertEqual(userDefs.string(forKey: MediaKeysControlsPreferences.key_skipKeyBehavior), prefs.skipKeyBehavior.rawValue)
        XCTAssertEqual(userDefs.string(forKey: MediaKeysControlsPreferences.key_repeatSpeed), prefs.repeatSpeed.rawValue)
    }
    
    // MARK: Helper functions ------------------------------
    
    private func randomPreferences() -> MediaKeysControlsPreferences {
        
        let prefs = MediaKeysControlsPreferences([:])
        
        prefs.enabled = Bool.random()
        prefs.skipKeyBehavior = randomSkipKeyBehavior()
        prefs.repeatSpeed = randomRepeatSpeed()
        
        return prefs
    }
    
    private func randomSkipKeyBehavior() -> SkipKeyBehavior {SkipKeyBehavior.randomCase()}
    
    private func randomNillableSkipKeyBehavior() -> SkipKeyBehavior? {
        randomNillableValue {self.randomSkipKeyBehavior()}
    }
    
    private func randomRepeatSpeed() -> SkipKeyRepeatSpeed {SkipKeyRepeatSpeed.randomCase()}
    
    private func randomNillableRepeatSpeed() -> SkipKeyRepeatSpeed? {
        randomNillableValue {self.randomRepeatSpeed()}
    }
}
