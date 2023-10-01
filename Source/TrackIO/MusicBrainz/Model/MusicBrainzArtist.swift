//
//  MusicBrainzArtist.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Represents an "artist" entity in the **MusicBrainz** domain model.
///
class MusicBrainzArtist {

    ///
    /// MusicBrainz identifier to uniquely identify this object.
    ///
    var id: String
    
    ///
    /// The name of this artist
    ///
    var name: String

    ///
    /// Conditionally initializes this object, given a dictionary containing key-value pairs corresponding to members of this object.
    ///
    /// NOTE - Returns nil if the input dictionary does not contain all the fields required for this object.
    ///
    init?(_ dict: NSDictionary) {

        // Validate the dictionary (all fields must be present).
        guard let id = dict["id", String.self],
              let name = dict["name", String.self] else {return nil}

        self.id = id
        self.name = name
    }
}
