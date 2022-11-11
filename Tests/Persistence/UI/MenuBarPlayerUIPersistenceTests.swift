//
//  MenuBarPlayerUIPersistenceTests.swift
//  Tests
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

class MenuBarPlayerUIPersistenceTests: PersistenceTestCase {
    
    func testPersistence() {
        
        let bools: [Bool] = [false, true]
        
        for showAlbum in bools {
            
            for showAlbumArt in bools {
                
                for showArtist in bools {
                    
                    for showCurrentChapter in bools {
                        
                        for _ in 1...10 {
                            
                            let state = MenuBarPlayerUIPersistentState(showAlbumArt: showAlbumArt,
                                                                       showArtist: showArtist,
                                                                       showAlbum: showAlbum,
                                                                       showCurrentChapter: showCurrentChapter)
                            
                            doTestPersistence(serializedState: state)
                        }
                    }
                }
            }
        }
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension MenuBarPlayerUIPersistentState: Equatable {
    
    static func == (lhs: MenuBarPlayerUIPersistentState, rhs: MenuBarPlayerUIPersistentState) -> Bool {
        
        lhs.showAlbum == rhs.showAlbum &&
            lhs.showAlbumArt == rhs.showAlbumArt &&
            lhs.showArtist == rhs.showArtist &&
            lhs.showCurrentChapter == rhs.showCurrentChapter
    }
}
