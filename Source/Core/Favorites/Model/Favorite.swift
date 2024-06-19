//
//  Favorite.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Encapsulates a user-defined favorite (a track marked as such).
///
class Favorite: Hashable {
    
    var name: String
    
    var key: String {
        get {""}
    }
    
    init(name: String) {
        self.name = name
    }
    
    static func == (lhs: Favorite, rhs: Favorite) -> Bool {
        lhs.key == rhs.key
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(key)
    }
}

//enum PlayableItemType: String, Codable {
//    
//    case track
//    case playlist
//    case artist
//    case album
//    case genre
//    case decade
//    case folder
//}
