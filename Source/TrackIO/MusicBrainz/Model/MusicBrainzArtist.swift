import Foundation

///
/// Used to represent an "artist" entity in the Music Brainz domain model.
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
        guard let id = dict["id"] as? String,
              let name = dict["name"] as? String else {return nil}

        self.id = id
        self.name = name
    }
}
