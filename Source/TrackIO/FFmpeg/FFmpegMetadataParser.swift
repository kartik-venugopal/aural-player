import Foundation

///
/// A contract for a parser that reads metadata from a non-native track, i.e. a track that
/// is read using ffmpeg.
///
protocol FFmpegMetadataParser {
    
    ///
    /// Separates out all metadata contained in the given track metadata map, that is recognized by this parser,
    /// for efficient future lookups.
    ///
    func mapMetadata(_ metadataMap: FFmpegMappedMetadata)
    
    ///
    /// Determines whether or not the given track metadata map contains any essential metadata that is recognized by this parser.
    ///
    func hasEssentialMetadataForTrack(_ metadataMap: FFmpegMappedMetadata) -> Bool
    
    ///
    /// Determines whether or not the given track metadata map contains any non-essential metadata that is recognized by this parser.
    ///
    func hasGenericMetadataForTrack(_ metadataMap: FFmpegMappedMetadata) -> Bool
    
    ///
    /// Read track title from the given metadata map. Returns nil if not present.
    ///
    func getTitle(_ metadataMap: FFmpegMappedMetadata) -> String?
    
    ///
    /// Read track artist from the given metadata map. Returns nil if not present.
    ///
    func getArtist(_ metadataMap: FFmpegMappedMetadata) -> String?
    
    ///
    /// Read track album from the given metadata map. Returns nil if not present.
    ///
    func getAlbum(_ metadataMap: FFmpegMappedMetadata) -> String?
    
    ///
    /// Read track genre from the given metadata map. Returns nil if not present.
    ///
    func getGenre(_ metadataMap: FFmpegMappedMetadata) -> String?
    
    ///
    /// Read track lyrics from the given metadata map. Returns nil if not present.
    ///
    func getLyrics(_ metadataMap: FFmpegMappedMetadata) -> String?
    
    ///
    /// Read album disc number (disc number and total discs) from the given metadata map. Returns nil if not present.
    ///
    func getDiscNumber(_ metadataMap: FFmpegMappedMetadata) -> (number: Int?, total: Int?)?
    
    ///
    /// Read album total disc count from the given metadata map. Returns nil if not present.
    ///
    func getTotalDiscs(_ metadataMap: FFmpegMappedMetadata) -> Int?
    
    ///
    /// Read album / disc track number (track number and total tracks) from the given metadata map. Returns nil if not present.
    ///
    func getTrackNumber(_ metadataMap: FFmpegMappedMetadata) -> (number: Int?, total: Int?)?
    
    ///
    /// Read album / disc total track count from the given metadata map. Returns nil if not present.
    ///
    func getTotalTracks(_ metadataMap: FFmpegMappedMetadata) -> Int?
    
    ///
    /// Read track duration from the given metadata map. Returns nil if not present.
    ///
    func getDuration(_ metadataMap: FFmpegMappedMetadata) -> Double?
    
    ///
    /// Reads whether or not the track is protected by DRM, from the given metadata map. Returns nil if not present.
    ///
    func isDRMProtected(_ metadataMap: FFmpegMappedMetadata) -> Bool?
    
    ///
    /// Read all auxiliary (non-essential) metadata from the given metadata map.
    /// Returns a map of key -> MetadataEntry.
    ///
    func getAuxiliaryMetadata(_ metadataMap: FFmpegMappedMetadata) -> [String: MetadataEntry]
}

// Default function implementations
extension FFmpegMetadataParser {
    
    func getTitle(_ metadataMap: FFmpegMappedMetadata) -> String? {nil}
    
    func getArtist(_ metadataMap: FFmpegMappedMetadata) -> String? {nil}
    
    func getAlbum(_ metadataMap: FFmpegMappedMetadata) -> String? {nil}
    
    func getGenre(_ metadataMap: FFmpegMappedMetadata) -> String? {nil}
    
    func getLyrics(_ metadataMap: FFmpegMappedMetadata) -> String? {nil}
    
    func getDiscNumber(_ metadataMap: FFmpegMappedMetadata) -> (number: Int?, total: Int?)? {nil}
    
    func getTotalDiscs(_ metadataMap: FFmpegMappedMetadata) -> Int? {nil}
    
    func getTrackNumber(_ metadataMap: FFmpegMappedMetadata) -> (number: Int?, total: Int?)? {nil}
    
    func getTotalTracks(_ metadataMap: FFmpegMappedMetadata) -> Int? {nil}
 
    func getDuration(_ metadataMap: FFmpegMappedMetadata) -> Double? {nil}
    
    func isDRMProtected(_ metadataMap: FFmpegMappedMetadata) -> Bool? {nil}
    
    func getAuxiliaryMetadata(_ metadataMap: FFmpegMappedMetadata) -> [String: MetadataEntry] {[:]}
}
