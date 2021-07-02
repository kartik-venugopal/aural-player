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

class PlaybackPreferencesTests: AuralTestCase {
    
    func test() {
        
        let primarySeekLengthOption: SeekLengthOptions = .constant
        let primarySeekLengthConstant: Int = 5
        let primarySeekLengthPercentage: Int = 1
        
        let secondarySeekLengthOption: SeekLengthOptions = .percentage
        let secondarySeekLengthConstant: Int = 30
        let secondarySeekLengthPercentage: Int = 10

        let autoplayOnStartup: Bool = false
        let autoplayAfterAddingTracks: Bool = true
        let autoplayAfterAddingOption: AutoplayAfterAddingOptions = .always

        let rememberLastPositionOption: RememberSettingsForTrackOptions = .individualTracks
        
        let userDefs: UserDefaults = UserDefaults()
        
        userDefs[PlaybackPreferences.key_primarySeekLengthOption] = primarySeekLengthOption.rawValue
        userDefs[PlaybackPreferences.key_primarySeekLengthConstant] = primarySeekLengthConstant
        userDefs[PlaybackPreferences.key_primarySeekLengthPercentage] = primarySeekLengthPercentage
        
        userDefs[PlaybackPreferences.key_secondarySeekLengthOption] = secondarySeekLengthOption.rawValue
        userDefs[PlaybackPreferences.key_secondarySeekLengthConstant] = secondarySeekLengthConstant
        userDefs[PlaybackPreferences.key_secondarySeekLengthPercentage] = secondarySeekLengthPercentage
        
        userDefs[PlaybackPreferences.key_autoplayOnStartup] = autoplayOnStartup
        userDefs[PlaybackPreferences.key_autoplayAfterAddingTracks] = autoplayAfterAddingTracks
        userDefs[PlaybackPreferences.key_autoplayAfterAddingOption] = autoplayAfterAddingOption.rawValue
        
        userDefs[PlaybackPreferences.key_rememberLastPositionOption] = rememberLastPositionOption.rawValue
        
        let prefs = PlaybackPreferences(userDefs.dictionaryRepresentation())
        
        XCTAssertEqual(prefs.primarySeekLengthOption, primarySeekLengthOption)
        XCTAssertEqual(prefs.primarySeekLengthConstant, primarySeekLengthConstant)
        XCTAssertEqual(prefs.primarySeekLengthPercentage, primarySeekLengthPercentage)
        
        XCTAssertEqual(prefs.secondarySeekLengthOption, secondarySeekLengthOption)
        XCTAssertEqual(prefs.secondarySeekLengthConstant, secondarySeekLengthConstant)
        XCTAssertEqual(prefs.secondarySeekLengthPercentage, secondarySeekLengthPercentage)
        
        XCTAssertEqual(prefs.autoplayOnStartup, autoplayOnStartup)
        XCTAssertEqual(prefs.autoplayAfterAddingTracks, autoplayAfterAddingTracks)
        XCTAssertEqual(prefs.autoplayAfterAddingOption, autoplayAfterAddingOption)
        
        XCTAssertEqual(prefs.rememberLastPositionOption, rememberLastPositionOption)
    }
}
