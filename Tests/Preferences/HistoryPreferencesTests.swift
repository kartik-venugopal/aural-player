//
//  HistoryPreferencesTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class HistoryPreferencesTests: PreferencesTestCase {
    
    private typealias Defaults = PreferencesDefaults.History
    
    // MARK: init() tests ------------------------------
    
    func testInit_noValues() {
        
        doTestInit(userDefs: UserDefaults(),
                   recentlyAddedListSize: nil,
                   recentlyPlayedListSize: nil)
    }
    
    func testInit_someValues() {
        
        for _ in 1...100 {
            
            resetDefaults()
            
            doTestInit(userDefs: UserDefaults(),
                       recentlyAddedListSize: randomNillableHistoryListSize(),
                       recentlyPlayedListSize: randomNillableHistoryListSize())
        }
    }
    
    func testInit() {
        
        for _ in 1...100 {
            
            resetDefaults()
            
            doTestInit(userDefs: UserDefaults(),
                       recentlyAddedListSize: randomHistoryListSize(),
                       recentlyPlayedListSize: randomHistoryListSize())
        }
    }
    
    private func doTestInit(userDefs: UserDefaults,
                            recentlyAddedListSize: Int?,
                            recentlyPlayedListSize: Int?) {
        
        userDefs[HistoryPreferences.key_recentlyAddedListSize] = recentlyAddedListSize
        userDefs[HistoryPreferences.key_recentlyPlayedListSize] = recentlyPlayedListSize
        
        let prefs = HistoryPreferences(userDefs.dictionaryRepresentation())
        
        XCTAssertEqual(prefs.recentlyAddedListSize, recentlyAddedListSize ?? Defaults.recentlyAddedListSize)
        XCTAssertEqual(prefs.recentlyPlayedListSize, recentlyPlayedListSize ?? Defaults.recentlyPlayedListSize)
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
            
            let deserializedPrefs = HistoryPreferences(UserDefaults.standard.dictionaryRepresentation())
            compare(prefs: deserializedPrefs, userDefs: .standard)
        }
    }
    
    private func doTestPersist(prefs: HistoryPreferences) {
        doTestPersist(prefs: prefs, userDefs: UserDefaults())
    }
    
    private func doTestPersist(prefs: HistoryPreferences, userDefs: UserDefaults) {
        
        prefs.persist(to: userDefs)
        compare(prefs: prefs, userDefs: userDefs)
    }
    
    private func compare(prefs: HistoryPreferences, userDefs: UserDefaults) {
        
        XCTAssertEqual(userDefs.integer(forKey: HistoryPreferences.key_recentlyAddedListSize), prefs.recentlyAddedListSize)
        XCTAssertEqual(userDefs.integer(forKey: HistoryPreferences.key_recentlyPlayedListSize), prefs.recentlyPlayedListSize)
    }
    
    // MARK: Helper functions ------------------------------
    
    private func randomPreferences() -> HistoryPreferences {
        
        let prefs = HistoryPreferences([:])
        
        prefs.recentlyAddedListSize = randomHistoryListSize()
        prefs.recentlyPlayedListSize = randomHistoryListSize()
        
        return prefs
    }
    
    private func randomNillableHistoryListSize() -> Int? {
        randomNillableValue {self.randomHistoryListSize()}
    }
    
    private func randomHistoryListSize() -> Int {Int.random(in: 10...100)}
}
