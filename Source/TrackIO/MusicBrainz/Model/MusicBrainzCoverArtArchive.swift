//
//  MusicBrainzCoverArtArchive.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Represents the cover art archive for a single "release" entity in the **MusicBrainz** domain model.
/// Contains information (metadata) about all the cover art available for a single release.
///
class MusicBrainzCoverArtArchive {

    ///
    /// Whether or not this archive contains any artwork.
    ///
    var artwork: Bool
    
    ///
    /// Whether or not this archive contains any artwork that is considered a "back cover" (like the back cover image on a CD).
    ///
    var back: Bool
    
    ///
    /// Whether or not this archive contains any artwork that is considered a "front cover" (like the front cover image on a CD).
    ///
    var front: Bool
    
    ///
    /// The total count of artwork contained in this archive (including all front / back / other images).
    ///
    var count: Int
    
    ///
    /// Whether or not this archive contains any artwork.
    ///
    var hasArt: Bool {count > 0}
    
    ///
    /// Conditionally initializes this object, given a dictionary containing key-value pairs corresponding to members of this object.
    ///
    /// NOTE - Returns nil if the input dictionary does not contain all the fields required for this object.
    ///
    init?(_ dict: NSDictionary) {

        // Validate the dictionary (all fields must be present).
        guard let artwork = dict["artwork", Bool.self],
              let back = dict["back", Bool.self],
              let front = dict["front", Bool.self],
              let count = dict.intValue(forKey: "count") else {return nil}
       
        self.artwork = artwork
        self.back = back
        self.front = front
        self.count = count
    }
}
