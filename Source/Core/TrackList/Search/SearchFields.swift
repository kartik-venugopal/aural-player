//
//  SearchFields.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

///
/// Enumerates the track fields used as playlist search criteria.
///
struct SearchFields: OptionSet, Codable {
    
    let rawValue: Int
    
    static let name = SearchFields(rawValue: 1 << 0)
    static let artist = SearchFields(rawValue: 1 << 1)
    static let title = SearchFields(rawValue: 1 << 2)
    static let album = SearchFields(rawValue: 1 << 3)

    /** TODO:
     
     var composer: String?
     var conductor: String?
     var performer: String?
     var lyricist: String?
     
     */
//    static let secondaryArtist = SearchFields(rawValue: 1 << 4)
    
    static let none: SearchFields = []
    static let all: SearchFields = [name, artist, title, album]
    
    // TODO: Allow searching of 'any' arbitrary field
}
