import Foundation

///
/// Used to represent the cover art archive for a single "release" entity in the Music Brainz domain model.
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
        guard let artwork = dict["artwork"] as? Bool,
              let back = dict["back"] as? Bool,
              let front = dict["front"] as? Bool,
              let count = dict["count"] as? NSNumber else {return nil}
       
        self.artwork = artwork
        self.back = back
        self.front = front
        self.count = count.intValue
    }
}

/// This class is currently unused.
class MusicBrainzCoverArtImage {
    
    var thumbnails: [String: String] = [:]
    var image: String
    var approved: Bool
    var front: Bool
    
    init?(_ dict: NSDictionary) {

        // Validate the dictionary (all fields must be present).
        guard let image = dict["image"] as? String else {return nil}
        self.image = image
       
        if let thumbnails = dict["thumbnails"] as? NSDictionary {
            
            for (size, url) in thumbnails {
                
                if let sizeStr = size as? String, let urlStr = url as? String {
                    self.thumbnails[sizeStr] = urlStr
                }
            }
        }
        
        self.approved = dict["approved"] as? Bool ?? false
        self.front = dict["front"] as? Bool ?? false
    }
}
