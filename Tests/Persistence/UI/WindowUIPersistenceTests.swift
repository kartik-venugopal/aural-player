//
//  WindowUIPersistenceTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

class WindowUIPersistenceTests: PersistenceTestCase {
    
    func testPersistence() {
        
        for cornerRadius in 0...25 {
            doTestPersistence(serializedState: WindowUIPersistentState(cornerRadius: CGFloat(cornerRadius)))
        }
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension WindowUIPersistentState: Equatable {
    
    static func == (lhs: WindowUIPersistentState, rhs: WindowUIPersistentState) -> Bool {
        CGFloat.approxEquals(lhs.cornerRadius, rhs.cornerRadius, accuracy: 0.001)
    }
}
