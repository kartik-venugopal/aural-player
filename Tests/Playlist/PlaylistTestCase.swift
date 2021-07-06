//
//  PlaylistTestCase.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class PlaylistTestCase: AuralTestCase {

    var testPlaylistSizes: [Int] {
        
        var sizes: [Int] = [1, 2, 3, 5, 10, 50, 100, 500, 1000]
        
        if runLongRunningTests {sizes.append(10000)}
        
        let numRandomSizes = runLongRunningTests ? 100 : 10
        let maxSize = runLongRunningTests ? 10000 : 1000
        
        for _ in 1...numRandomSizes {
            sizes.append(Int.random(in: 5...maxSize))
        }
        
        return sizes
    }
}

