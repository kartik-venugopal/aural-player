import Cocoa
import AVFoundation

/*
    Contract for a metadata specification
 */
protocol AVAssetParser {
    
    func mapTrack(_ track: Track, _ mapForTrack: AVAssetMetadata)
    
    func getDuration(mapForTrack: AVAssetMetadata) -> Double?
    
    func getTitle(mapForTrack: AVAssetMetadata) -> String?
    
    func getArtist(mapForTrack: AVAssetMetadata) -> String?
    
    func getAlbum(mapForTrack: AVAssetMetadata) -> String?
    
    func getGenre(mapForTrack: AVAssetMetadata) -> String?
    
    func getLyrics(mapForTrack: AVAssetMetadata) -> String?
    
    func getDiscNumber(mapForTrack: AVAssetMetadata) -> (number: Int?, total: Int?)?
    
    func getTrackNumber(mapForTrack: AVAssetMetadata) -> (number: Int?, total: Int?)?
    
    func getArt(mapForTrack: AVAssetMetadata) -> NSImage?
    
    func getArt(_ asset: AVURLAsset) -> NSImage?
    
    func getGenericMetadata(mapForTrack: AVAssetMetadata) -> [String: MetadataEntry]
    
    // For a format-specific key, return a descriptive user-friendly key
    static func readableKey(_ key: String) -> String
}

protocol FFMpegMetadataParser {
    
    func getDuration(mapForTrack: LibAVMetadata) -> Double?
    
    func getTitle(mapForTrack: LibAVMetadata) -> String?
    
    func getArtist(mapForTrack: LibAVMetadata) -> String?
    
    func getAlbum(mapForTrack: LibAVMetadata) -> String?
    
    func getGenre(mapForTrack: LibAVMetadata) -> String?
    
    func getLyrics(mapForTrack: LibAVMetadata) -> String?
    
    func getDiscNumber(mapForTrack: LibAVMetadata) -> (number: Int?, total: Int?)?
    
    func getTrackNumber(mapForTrack: LibAVMetadata) -> (number: Int?, total: Int?)?
    
    func getArt(mapForTrack: LibAVMetadata) -> NSImage?
    
    func getArt(_ asset: AVURLAsset) -> NSImage?
    
    func getGenericMetadata(mapForTrack: LibAVMetadata) -> [String: MetadataEntry]
    
    // For a format-specific key, return a descriptive user-friendly key
    static func readableKey(_ key: String) -> String
}
