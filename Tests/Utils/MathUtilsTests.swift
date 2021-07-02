//
//  MathUtilsTests.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

/*
    Unit tests for MathUtils global functions
 */
class MathUtilsTests: XCTestCase {

    func testRoundedInt_Float() {
        
        XCTAssertEqual(Float(5.5).roundedInt, 6)
        XCTAssertEqual(Float(5).roundedInt, 5)
        XCTAssertEqual(Float(5.0000001).roundedInt, 5)
        XCTAssertEqual(Float(4.99).roundedInt, 5)
        XCTAssertEqual(Float(4.499999).roundedInt, 4)
    }
    
    func testRoundedInt_Double() {
        
        XCTAssertEqual(Double(5.5).roundedInt, 6)
        XCTAssertEqual(Double(5.0).roundedInt, 5)
        XCTAssertEqual(Double(5.0000001).roundedInt, 5)
        XCTAssertEqual(Double(4.99).roundedInt, 5)
        XCTAssertEqual(Double(4.499999).roundedInt, 4)
    }
    
    func testFloorInt_Float() {
        
        XCTAssertEqual(Float(5.5).floorInt, 5)
        XCTAssertEqual(Float(5.75).floorInt, 5)
        XCTAssertEqual(Float(5).floorInt, 5)
        XCTAssertEqual(Float(5.0000001).floorInt, 5)
        XCTAssertEqual(Float(4.999999).floorInt, 4)
        XCTAssertEqual(Float(4.499999).floorInt, 4)
    }
    
    func testFloorInt_Double() {
        
        XCTAssertEqual(Double(5.5).floorInt, 5)
        XCTAssertEqual(Double(5.75).floorInt, 5)
        XCTAssertEqual(Double(5.0).floorInt, 5)
        XCTAssertEqual(Double(5.0000001).floorInt, 5)
        XCTAssertEqual(Double(4.999999).floorInt, 4)
        XCTAssertEqual(Double(4.499999).floorInt, 4)
    }
}
