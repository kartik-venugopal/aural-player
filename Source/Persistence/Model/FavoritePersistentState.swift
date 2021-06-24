//
//  FavoritePersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

class FavoritePersistentState: PersistentStateProtocol {

    let file: URL
    let name: String
    
    init(file: URL, name: String) {
        
        self.file = file
        self.name = name
    }
    
    required init?(_ map: NSDictionary) {
        
        guard let file = map.urlValue(forKey: "file"),
              let name = map["name", String.self] else {return nil}
        
        self.file = file
        self.name = name
    }
}
