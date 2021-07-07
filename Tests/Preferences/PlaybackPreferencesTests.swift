//
//  PlaybackPreferencesTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class PlaybackPreferencesTests: PreferencesTestCase {
    
    private typealias Defaults = PreferencesDefaults.Playback
    
    // MARK: init() tests ------------------------------
    
    func testInit_noValues() {
        
        doTestInit(userDefs: UserDefaults(),
                   primarySeekLengthOption: nil,
                   primarySeekLengthConstant: nil,
                   primarySeekLengthPercentage: nil,
                   secondarySeekLengthOption: nil,
                   secondarySeekLengthConstant: nil,
                   secondarySeekLengthPercentage: nil,
                   autoplayOnStartup: nil,
                   autoplayAfterAddingTracks: nil,
                   autoplayAfterAddingOption: nil,
                   rememberLastPositionOption: nil)
    }
    
    func testInit_someValues() {
        
        for _ in 1...100 {
            
            doTestInit(userDefs: UserDefaults(),
                       primarySeekLengthOption: randomNillableSeekLengthOption(),
                       primarySeekLengthConstant: randomNillableSeekLengthConstant(),
                       primarySeekLengthPercentage: randomNillablePercentage(),
                       secondarySeekLengthOption: randomNillableSeekLengthOption(),
                       secondarySeekLengthConstant: randomNillableSeekLengthConstant(),
                       secondarySeekLengthPercentage: randomNillablePercentage(),
                       autoplayOnStartup: randomNillableBool(),
                       autoplayAfterAddingTracks: randomNillableBool(),
                       autoplayAfterAddingOption: randomNillableAutoplayAfterAddingOption(),
                       rememberLastPositionOption: randomNillableRememberLastPositionOption())
            
        }
    }
    
    func testInit() {
        
        for _ in 1...100 {
            
            doTestInit(userDefs: UserDefaults(),
                       primarySeekLengthOption: randomSeekLengthOption(),
                       primarySeekLengthConstant: randomSeekLengthConstant(),
                       primarySeekLengthPercentage: randomPercentage(),
                       secondarySeekLengthOption: randomSeekLengthOption(),
                       secondarySeekLengthConstant: randomSeekLengthConstant(),
                       secondarySeekLengthPercentage: randomPercentage(),
                       autoplayOnStartup: .random(),
                       autoplayAfterAddingTracks: .random(),
                       autoplayAfterAddingOption: randomAutoplayAfterAddingOption(),
                       rememberLastPositionOption: randomRememberLastPositionOption())
        }
    }
    
    private func doTestInit(userDefs: UserDefaults,
                            primarySeekLengthOption: SeekLengthOptions?,
                            primarySeekLengthConstant: Int?,
                            primarySeekLengthPercentage: Int?,
                            secondarySeekLengthOption: SeekLengthOptions?,
                            secondarySeekLengthConstant: Int?,
                            secondarySeekLengthPercentage: Int?,
                            autoplayOnStartup: Bool?,
                            autoplayAfterAddingTracks: Bool?,
                            autoplayAfterAddingOption: AutoplayAfterAddingOptions?,
                            rememberLastPositionOption: RememberSettingsForTrackOptions?) {
        
        userDefs[PlaybackPreferences.key_primarySeekLengthOption] = primarySeekLengthOption?.rawValue
        userDefs[PlaybackPreferences.key_primarySeekLengthConstant] = primarySeekLengthConstant
        userDefs[PlaybackPreferences.key_primarySeekLengthPercentage] = primarySeekLengthPercentage
        
        userDefs[PlaybackPreferences.key_secondarySeekLengthOption] = secondarySeekLengthOption?.rawValue
        userDefs[PlaybackPreferences.key_secondarySeekLengthConstant] = secondarySeekLengthConstant
        userDefs[PlaybackPreferences.key_secondarySeekLengthPercentage] = secondarySeekLengthPercentage
        
        userDefs[PlaybackPreferences.key_autoplayOnStartup] = autoplayOnStartup
        userDefs[PlaybackPreferences.key_autoplayAfterAddingTracks] = autoplayAfterAddingTracks
        userDefs[PlaybackPreferences.key_autoplayAfterAddingOption] = autoplayAfterAddingOption?.rawValue
        
        userDefs[PlaybackPreferences.key_rememberLastPositionOption] = rememberLastPositionOption?.rawValue
        
        let prefs = PlaybackPreferences(userDefs.dictionaryRepresentation())
        
        XCTAssertEqual(prefs.primarySeekLengthOption, primarySeekLengthOption ?? Defaults.primarySeekLengthOption)
        XCTAssertEqual(prefs.primarySeekLengthConstant, primarySeekLengthConstant ?? Defaults.primarySeekLengthConstant)
        XCTAssertEqual(prefs.primarySeekLengthPercentage, primarySeekLengthPercentage ?? Defaults.primarySeekLengthPercentage)
        
        XCTAssertEqual(prefs.secondarySeekLengthOption, secondarySeekLengthOption ?? Defaults.secondarySeekLengthOption)
        XCTAssertEqual(prefs.secondarySeekLengthConstant, secondarySeekLengthConstant ?? Defaults.secondarySeekLengthConstant)
        XCTAssertEqual(prefs.secondarySeekLengthPercentage, secondarySeekLengthPercentage ?? Defaults.secondarySeekLengthPercentage)
        
        XCTAssertEqual(prefs.autoplayOnStartup, autoplayOnStartup ?? Defaults.autoplayOnStartup)
        XCTAssertEqual(prefs.autoplayAfterAddingTracks, autoplayAfterAddingTracks ?? Defaults.autoplayAfterAddingTracks)
        XCTAssertEqual(prefs.autoplayAfterAddingOption, autoplayAfterAddingOption ?? Defaults.autoplayAfterAddingOption)
        
        XCTAssertEqual(prefs.rememberLastPositionOption, rememberLastPositionOption ?? Defaults.rememberLastPositionOption)
    }
    
    // MARK: persist() tests ------------------------------
    
    func testPersist() {
        
        for _ in 1...100 {
            doTestPersist(prefs: randomPlaybackPreferences())
        }
    }
    
    func testPersist_serializeAndDeserialize() {
        
        for _ in 1...100 {
            
            let defaults = UserDefaults()
            let serializedPrefs = randomPlaybackPreferences()
            doTestPersist(prefs: serializedPrefs, userDefs: defaults)
            
            let deserializedPrefs = PlaybackPreferences(UserDefaults.standard.dictionaryRepresentation())
            compare(prefs: deserializedPrefs, userDefs: defaults)
        }
    }
    
    private func doTestPersist(prefs: PlaybackPreferences) {
        doTestPersist(prefs: prefs, userDefs: UserDefaults())
    }
    
    private func doTestPersist(prefs: PlaybackPreferences, userDefs: UserDefaults) {
        
        prefs.persist(to: userDefs)
        compare(prefs: prefs, userDefs: userDefs)
    }
}
