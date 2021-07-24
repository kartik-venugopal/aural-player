//
//  ThemesPersistenceTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class ThemesPersistenceTests: PersistenceTestCase {
    
    func testPersistence() {
        
        for _ in 1...(runLongRunningTests ? 1000 : 100) {
            doTestPersistence(serializedState: ThemesPersistentState(userThemes: randomThemes()))
        }
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension ThemesPersistentState: Equatable {
    
    static func == (lhs: ThemesPersistentState, rhs: ThemesPersistentState) -> Bool {
        lhs.userThemes == rhs.userThemes
    }
}

extension ThemePersistentState: Equatable {
    
    internal init(name: String?, fontScheme: FontSchemePersistentState?, colorScheme: ColorSchemePersistentState?,
                  windowAppearance: WindowAppearancePersistentState?) {
        
        self.name = name
        self.fontScheme = fontScheme
        self.colorScheme = colorScheme
        self.windowAppearance = windowAppearance
    }
    
    static func == (lhs: ThemePersistentState, rhs: ThemePersistentState) -> Bool {
        
        lhs.name == rhs.name &&
            lhs.fontScheme == rhs.fontScheme &&
            lhs.colorScheme == rhs.colorScheme &&
            lhs.windowAppearance == rhs.windowAppearance
    }
}
