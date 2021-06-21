import Foundation

///
/// Used to represent a "recording" entity in the Music Brainz domain model.
/// A recording roughly translates to a single track.
/// A single recording can be linked to several releases (albums / singles / compilations).
///
class MusicBrainzRecording {
    
    ///
    /// MusicBrainz identifier to uniquely identify this object.
    ///
    var id: String
    
    ///
    /// The releases (albums / singles / compilations) that this recording is linked to (i.e. a part of).
    ///
    var releases: [MusicBrainzRelease]
    
    ///
    /// Conditionally initializes this object, given a dictionary containing key-value pairs corresponding to members of this object.
    ///
    /// NOTE - Returns nil if the input dictionary does not contain all the fields required for this object.
    ///
    init?(_ dict: NSDictionary) {
        
        // Validate the dictionary (all fields must be present, and there must be at least one release).
        guard let id = dict["id", String.self],
              let releaseDicts = dict["releases", [NSDictionary].self],
              !releaseDicts.isEmpty else {return nil}
        
        self.id = id
        
        // Map the NSDictionary array to MBRelease objects, eliminating nil values.
        self.releases = releaseDicts.compactMap {MusicBrainzRelease($0)}
        
        // There must be at least one release.
        if self.releases.isEmpty {
            return nil
        }
    }
}
