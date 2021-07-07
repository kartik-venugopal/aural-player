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
    
    override func setUp() {
        
        UserDefaults.standard[PlaybackPreferences.key_primarySeekLengthOption] = nil
        UserDefaults.standard[PlaybackPreferences.key_primarySeekLengthConstant] = nil
        UserDefaults.standard[PlaybackPreferences.key_primarySeekLengthPercentage] = nil
        
        UserDefaults.standard[PlaybackPreferences.key_secondarySeekLengthOption] = nil
        UserDefaults.standard[PlaybackPreferences.key_secondarySeekLengthConstant] = nil
        UserDefaults.standard[PlaybackPreferences.key_secondarySeekLengthPercentage] = nil
        
        UserDefaults.standard[PlaybackPreferences.key_autoplayOnStartup] = nil
        UserDefaults.standard[PlaybackPreferences.key_autoplayAfterAddingTracks] = nil
        UserDefaults.standard[PlaybackPreferences.key_autoplayAfterAddingOption] = nil
        
        UserDefaults.standard[PlaybackPreferences.key_rememberLastPositionOption] = nil
    }
    
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
            
            resetDefaults()
            
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
            
            resetDefaults()
            
            doTestInit(userDefs: UserDefaults(),
                       primarySeekLengthOption: randomSeekLengthOption(),
                       primarySeekLengthConstant: randomSeekLengthConstant(),
                       primarySeekLengthPercentage: randomPercentage(),
                       secondarySeekLengthOption: randomSeekLengthOption(),
                       secondarySeekLengthConstant: randomSeekLengthConstant(),
                       secondarySeekLengthPercentage: randomPercentage(),
                       autoplayOnStartup: Bool.random(),
                       autoplayAfterAddingTracks: Bool.random(),
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
            
            resetDefaults()
            doTestPersist(prefs: randomPreferences())
        }
    }
    
    func testPersist_serializeAndDeserialize() {
        
        for _ in 1...100 {
            
            resetDefaults()
            
            let serializedPrefs = randomPreferences()
            doTestPersist(prefs: serializedPrefs, userDefs: .standard)
            
            let deserializedPrefs = PlaybackPreferences(UserDefaults.standard.dictionaryRepresentation())
            compare(prefs: deserializedPrefs, userDefs: .standard)
        }
    }
    
    private func doTestPersist(prefs: PlaybackPreferences) {
        doTestPersist(prefs: prefs, userDefs: UserDefaults())
    }
    
    private func doTestPersist(prefs: PlaybackPreferences, userDefs: UserDefaults) {
        
        prefs.persist(to: userDefs)
        compare(prefs: prefs, userDefs: userDefs)
    }
    
    private func compare(prefs: PlaybackPreferences, userDefs: UserDefaults) {
        
        XCTAssertEqual(userDefs.string(forKey: PlaybackPreferences.key_primarySeekLengthOption), prefs.primarySeekLengthOption.rawValue)
        XCTAssertEqual(userDefs.integer(forKey: PlaybackPreferences.key_primarySeekLengthConstant), prefs.primarySeekLengthConstant)
        XCTAssertEqual(userDefs.integer(forKey: PlaybackPreferences.key_primarySeekLengthPercentage), prefs.primarySeekLengthPercentage)
        
        XCTAssertEqual(userDefs.string(forKey: PlaybackPreferences.key_secondarySeekLengthOption), prefs.secondarySeekLengthOption.rawValue)
        XCTAssertEqual(userDefs.integer(forKey: PlaybackPreferences.key_secondarySeekLengthConstant), prefs.secondarySeekLengthConstant)
        XCTAssertEqual(userDefs.integer(forKey: PlaybackPreferences.key_secondarySeekLengthPercentage), prefs.secondarySeekLengthPercentage)
        
        XCTAssertEqual(userDefs.bool(forKey: PlaybackPreferences.key_autoplayOnStartup), prefs.autoplayOnStartup)
        XCTAssertEqual(userDefs.bool(forKey: PlaybackPreferences.key_autoplayAfterAddingTracks), prefs.autoplayAfterAddingTracks)
        XCTAssertEqual(userDefs.string(forKey: PlaybackPreferences.key_autoplayAfterAddingOption), prefs.autoplayAfterAddingOption.rawValue)
        
        XCTAssertEqual(userDefs.string(forKey: PlaybackPreferences.key_rememberLastPositionOption), prefs.rememberLastPositionOption.rawValue)
    }
    
    // MARK: Helper functions ------------------------------
    
    private func randomPreferences() -> PlaybackPreferences {
        
        let prefs = PlaybackPreferences([:])
        
        prefs.primarySeekLengthOption = randomSeekLengthOption()
        prefs.primarySeekLengthConstant = randomSeekLengthConstant()
        prefs.primarySeekLengthPercentage = randomPercentage()
        prefs.secondarySeekLengthOption = randomSeekLengthOption()
        prefs.secondarySeekLengthConstant = randomSeekLengthConstant()
        prefs.secondarySeekLengthPercentage = randomPercentage()
        prefs.autoplayOnStartup = Bool.random()
        prefs.autoplayAfterAddingTracks = Bool.random()
        prefs.autoplayAfterAddingOption = randomAutoplayAfterAddingOption()
        prefs.rememberLastPositionOption = randomRememberLastPositionOption()
        
        return prefs
    }
    
    private func randomNillableSeekLengthConstant() -> Int? {
        randomNillableValue {self.randomSeekLengthConstant()}
    }
    
    private func randomSeekLengthConstant() -> Int {Int.random(in: 1...3600)}
    
    private func randomPercentage() -> Int {Int.random(in: 1...100)}
    
    private func randomNillablePercentage() -> Int? {
        randomNillableValue {self.randomPercentage()}
    }
    
    private func randomSeekLengthOption() -> SeekLengthOptions {SeekLengthOptions.randomCase()}
    
    private func randomNillableSeekLengthOption() -> SeekLengthOptions? {
        randomNillableValue {self.randomSeekLengthOption()}
    }
    
    private func randomAutoplayAfterAddingOption() -> AutoplayAfterAddingOptions {AutoplayAfterAddingOptions.randomCase()}
    
    private func randomNillableAutoplayAfterAddingOption() -> AutoplayAfterAddingOptions? {
        randomNillableValue {self.randomAutoplayAfterAddingOption()}
    }
    
    private func randomRememberLastPositionOption() -> RememberSettingsForTrackOptions {RememberSettingsForTrackOptions.randomCase()}
    
    private func randomNillableRememberLastPositionOption() -> RememberSettingsForTrackOptions? {
        randomNillableValue {self.randomRememberLastPositionOption()}
    }
}
