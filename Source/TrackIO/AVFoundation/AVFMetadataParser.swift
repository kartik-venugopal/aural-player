import Cocoa
import AVFoundation

///
/// A contract for a parser that reads metadata from a natively supported track, i.e. a track
/// supported by AVFoundation.
///
protocol AVFMetadataParser {
    
    ///
    /// The metadata key space that this parser understands (e.g. ID3).
    ///
    var keySpace: AVMetadataKeySpace {get}
    
    ///
    /// Read track duration from the given metadata map. Returns nil if not present.
    ///
    func getDuration(_ meta: AVFMappedMetadata) -> Double?
    
    ///
    /// Read track title from the given metadata map. Returns nil if not present.
    ///
    func getTitle(_ meta: AVFMappedMetadata) -> String?
    
    ///
    /// Read track artist from the given metadata map. Returns nil if not present.
    ///
    func getArtist(_ meta: AVFMappedMetadata) -> String?
    
    ///
    /// Read track album from the given metadata map. Returns nil if not present.
    ///
    func getAlbum(_ meta: AVFMappedMetadata) -> String?
    
    ///
    /// Read track genre from the given metadata map. Returns nil if not present.
    ///
    func getGenre(_ meta: AVFMappedMetadata) -> String?
    
    ///
    /// Read track lyrics from the given metadata map. Returns nil if not present.
    ///
    func getLyrics(_ meta: AVFMappedMetadata) -> String?
    
    ///
    /// Read track disc number from the given metadata map. Returns nil if not present.
    ///
    func getDiscNumber(_ meta: AVFMappedMetadata) -> (number: Int?, total: Int?)?
    
    ///
    /// Read track number from the given metadata map. Returns nil if not present.
    ///
    func getTrackNumber(_ meta: AVFMappedMetadata) -> (number: Int?, total: Int?)?
    
    ///
    /// Read track cover art from the given metadata map. Returns nil if not present.
    ///
    func getArt(_ meta: AVFMappedMetadata) -> CoverArt?
    
    ///
    /// Read all auxiliary (non-essential) metadata from the given metadata map.
    /// Returns a map of key -> MetadataEntry.
    ///
    func getGenericMetadata(_ meta: AVFMappedMetadata) -> [String: MetadataEntry]

    ///
    /// Read a chapter's title from the given collection of metadata items. Returns nil if not present.
    ///
    func getChapterTitle(_ items: [AVMetadataItem]) -> String?
}

// Default function implementations
extension AVFMetadataParser {
    
    func getTitle(_ meta: AVFMappedMetadata) -> String? {nil}
    
    func getArtist(_ meta: AVFMappedMetadata) -> String? {nil}
    
    func getAlbum(_ meta: AVFMappedMetadata) -> String? {nil}
    
    func getGenre(_ meta: AVFMappedMetadata) -> String? {nil}
    
    func getDuration(_ meta: AVFMappedMetadata) -> Double? {nil}
    
    func getDiscNumber(_ meta: AVFMappedMetadata) -> (number: Int?, total: Int?)? {nil}
    
    func getTrackNumber(_ meta: AVFMappedMetadata) -> (number: Int?, total: Int?)? {nil}
    
    func getLyrics(_ meta: AVFMappedMetadata) -> String? {nil}
    
    func getArt(_ meta: AVFMappedMetadata) -> CoverArt? {nil}
    
    func getChapterTitle(_ items: [AVMetadataItem]) -> String? {nil}
    
    func getGenericMetadata(_ meta: AVFMappedMetadata) -> [String: MetadataEntry] {[:]}
}
