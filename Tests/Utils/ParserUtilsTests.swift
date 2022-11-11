//
//  ParserUtilsTests.swift
//  Tests
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class ParserUtilsTests: AuralTestCase {

    func testParseID3GenreString() {
        
        for (genreCode, genreString) in GenreMap.id3Map {
            
            let testString1 = "(\(genreCode))\(genreString)"
            let testString2 = "(\(genreCode)) \(genreString)"
            let testString3 = "(\(genreCode))\(genreString) "
            let testString4 = "(\(genreCode)) \(genreString) "
            
            for testString in [testString1, testString2, testString3, testString4] {
                XCTAssertEqual(ParserUtils.parseID3GenreString(testString), genreString)
            }
        }
    }
}
