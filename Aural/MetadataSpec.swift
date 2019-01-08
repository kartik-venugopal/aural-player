import Cocoa
import AVFoundation

/*
    Contract for a metadata specification
 */
protocol MetadataParser {
    
    func mapTrack(_ track: Track, _ mapForTrack: MappedMetadata)
    
    func getDuration(mapForTrack: MappedMetadata) -> Double?
    
    func getTitle(mapForTrack: MappedMetadata) -> String?
    
    func getArtist(mapForTrack: MappedMetadata) -> String?
    
    func getAlbum(mapForTrack: MappedMetadata) -> String?
    
    func getGenre(mapForTrack: MappedMetadata) -> String?
    
    func getLyrics(mapForTrack: MappedMetadata) -> String?
    
    func getDiscNumber(mapForTrack: MappedMetadata) -> (number: Int?, total: Int?)?
    
    func getTrackNumber(mapForTrack: MappedMetadata) -> (number: Int?, total: Int?)?
    
    func getArt(mapForTrack: MappedMetadata) -> NSImage?
    
    func getArt(_ asset: AVURLAsset) -> NSImage?
    
    func getGenericMetadata(mapForTrack: MappedMetadata) -> [String: MetadataEntry]
    
    // For a format-specific key, return a descriptive user-friendly key
    static func readableKey(_ key: String) -> String
}
