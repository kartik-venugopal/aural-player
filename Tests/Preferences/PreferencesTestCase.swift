//
//  PreferencesTestCase.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class PreferencesTestCase: AuralTestCase {
    
    override func setUp() {
        resetDefaults()
    }
    
    func resetDefaults() {
        
        let defaults = UserDefaults.standard
        defaults.dictionaryRepresentation().keys.forEach {defaults.removeObject(forKey: $0)}
    }
}
