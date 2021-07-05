//
//  MusicBrainzPreferencesTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class MusicBrainzPreferencesTests: AuralTestCase {
    
    private typealias Defaults = PreferencesDefaults.Metadata.MusicBrainz
    
    // MARK: init() tests ------------------------------
    
    func testInit_noValues() {
        
        doTestInit(userDefs: UserDefaults(),
                   httpTimeout: nil,
                   enableCoverArtSearch: nil,
                   enableOnDiskCoverArtCache: nil)
    }
    
    func testInit_someValues() {
        
        for _ in 1...100 {
            
            doTestInit(userDefs: UserDefaults(),
                       httpTimeout: randomNillableHTTPTimeout(),
                       enableCoverArtSearch: randomNillableBool(),
                       enableOnDiskCoverArtCache: randomNillableBool())
            
        }
    }
    
    func testInit() {
        
        for _ in 1...100 {
            
            doTestInit(userDefs: UserDefaults(),
                       httpTimeout: randomHTTPTimeout(),
                       enableCoverArtSearch: Bool.random(),
                       enableOnDiskCoverArtCache: Bool.random())
        }
    }
    
    private func doTestInit(userDefs: UserDefaults,
                            httpTimeout: Int?,
                            enableCoverArtSearch: Bool?,
                            enableOnDiskCoverArtCache: Bool?) {
        
        userDefs[MusicBrainzPreferences.key_httpTimeout] = httpTimeout
        userDefs[MusicBrainzPreferences.key_enableCoverArtSearch] = enableCoverArtSearch
        userDefs[MusicBrainzPreferences.key_enableOnDiskCoverArtCache] = enableOnDiskCoverArtCache
        
        let prefs = MusicBrainzPreferences(userDefs.dictionaryRepresentation())
        
        XCTAssertEqual(prefs.httpTimeout, httpTimeout ?? Defaults.httpTimeout)
        XCTAssertEqual(prefs.enableCoverArtSearch, enableCoverArtSearch ?? Defaults.enableCoverArtSearch)
        XCTAssertEqual(prefs.enableOnDiskCoverArtCache, enableOnDiskCoverArtCache ?? Defaults.enableOnDiskCoverArtCache)
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
            
            let deserializedPrefs = MusicBrainzPreferences(UserDefaults.standard.dictionaryRepresentation())
            compare(prefs: deserializedPrefs, userDefs: UserDefaults.standard)
        }
    }
    
    private func doTestPersist(prefs: MusicBrainzPreferences) {
        doTestPersist(prefs: prefs, userDefs: UserDefaults())
    }
    
    private func doTestPersist(prefs: MusicBrainzPreferences, userDefs: UserDefaults) {
        
        prefs.persist(to: userDefs)
        compare(prefs: prefs, userDefs: userDefs)
    }
    
    private func compare(prefs: MusicBrainzPreferences, userDefs: UserDefaults) {
        
        XCTAssertEqual(userDefs.integer(forKey: MusicBrainzPreferences.key_httpTimeout), prefs.httpTimeout)
        XCTAssertEqual(userDefs.bool(forKey: MusicBrainzPreferences.key_enableCoverArtSearch), prefs.enableCoverArtSearch)
        XCTAssertEqual(userDefs.bool(forKey: MusicBrainzPreferences.key_enableOnDiskCoverArtCache), prefs.enableOnDiskCoverArtCache)
    }
    
    // MARK: Helper functions ------------------------------
    
    private func randomPreferences() -> MusicBrainzPreferences {
        
        let prefs = MusicBrainzPreferences([:])
        
        prefs.httpTimeout = randomHTTPTimeout()
        prefs.enableCoverArtSearch = Bool.random()
        prefs.enableOnDiskCoverArtCache = Bool.random()
        
        return prefs
    }
    
    private func randomNillableHTTPTimeout() -> Int? {
        randomNillableValue {self.randomHTTPTimeout()}
    }
    
    private func randomHTTPTimeout() -> Int {Int.random(in: 1...60)}
}
