//
//  MetadataPreferencesTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class MetadataPreferencesTests: PreferencesTestCase {
    
    private typealias Defaults = PreferencesDefaults.Metadata.MusicBrainz
    
    // MARK: init() tests ------------------------------
    
    func testInit_noValues() {
        
        doTestInit(userDefs: UserDefaults(),
                   httpTimeout: nil,
                   enableCoverArtSearch: nil,
                   enableOnDiskCoverArtCache: nil)
    }
    
    func testInit() {
        
        for _ in 1...100 {
            
            doTestInit(userDefs: UserDefaults(),
                       httpTimeout: randomHTTPTimeout(),
                       enableCoverArtSearch: .random(),
                       enableOnDiskCoverArtCache: .random())
            
        }
    }
    
    private func doTestInit(userDefs: UserDefaults,
                            httpTimeout: Int?,
                            enableCoverArtSearch: Bool?,
                            enableOnDiskCoverArtCache: Bool?) {
        
        userDefs[MusicBrainzPreferences.key_httpTimeout] = httpTimeout
        userDefs[MusicBrainzPreferences.key_enableCoverArtSearch] = enableCoverArtSearch
        userDefs[MusicBrainzPreferences.key_enableOnDiskCoverArtCache] = enableOnDiskCoverArtCache
        
        let prefs = MetadataPreferences(userDefs.dictionaryRepresentation())
        
        XCTAssertEqual(prefs.musicBrainz.httpTimeout, httpTimeout ?? Defaults.httpTimeout)
        XCTAssertEqual(prefs.musicBrainz.enableCoverArtSearch, enableCoverArtSearch ?? Defaults.enableCoverArtSearch)
        XCTAssertEqual(prefs.musicBrainz.enableOnDiskCoverArtCache, enableOnDiskCoverArtCache ?? Defaults.enableOnDiskCoverArtCache)
    }
    
    // MARK: persist() tests ------------------------------
    
    func testPersist() {
        
        for _ in 1...100 {
            doTestPersist(prefs: randomMetadataPreferences())
        }
    }
    
    func testPersist_serializeAndDeserialize() {
        
        for _ in 1...100 {
            
            let defaults = UserDefaults()
            let serializedPrefs = randomMetadataPreferences()
            doTestPersist(prefs: serializedPrefs, userDefs: defaults)
            
            let deserializedPrefs = MetadataPreferences(UserDefaults.standard.dictionaryRepresentation())
            compare(prefs: deserializedPrefs, userDefs: defaults)
        }
    }
    
    private func doTestPersist(prefs: MetadataPreferences) {
        doTestPersist(prefs: prefs, userDefs: UserDefaults())
    }
    
    private func doTestPersist(prefs: MetadataPreferences, userDefs: UserDefaults) {
        
        prefs.persist(to: userDefs)
        compare(prefs: prefs, userDefs: userDefs)
    }
}
