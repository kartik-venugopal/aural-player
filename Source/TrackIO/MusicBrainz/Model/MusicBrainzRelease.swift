import Foundation

///
/// Used to represent a "release" entity in the Music Brainz domain model.
/// A release is either an album or a single or a compilation of tracks.
///
class MusicBrainzRelease {
    
    ///
    /// MusicBrainz identifier to uniquely identify this object.
    ///
    var id: String
    
    ///
    /// Title of this release.
    ///
    var title: String
    
    ///
    /// A collection of artists who have been credited for this release.
    ///
    var artistCredits: [MusicBrainzArtistCredit] = []
    
    ///
    /// Conditionally initializes this object, given a dictionary containing key-value pairs corresponding to members of this object.
    ///
    /// NOTE - Returns nil if the input dictionary does not contain all the fields required for this object.
    ///
    init?(_ dict: NSDictionary) {
        
        // Validate the dictionary (all fields must be present, and there must be at least one artist credit).
        guard let id = dict["id"] as? String,
              let title = dict["title"] as? String,
              let artistCredits = dict["artist-credit"] as? [NSDictionary],
              !artistCredits.isEmpty else {return nil}
        
        self.id = id
        self.title = title
        
        // Map the NSDictionary array to MBArtistCredit objects, eliminating nil values.
        self.artistCredits = artistCredits.compactMap {MusicBrainzArtistCredit($0)}
        
        // There must be at least one artist credit.
        if self.artistCredits.isEmpty {
            return nil
        }
    }
}
