import Cocoa
import AVFoundation

protocol AVFMetadataParser {
    
    var keySpace: AVMetadataKeySpace {get}
    
    func getDuration(_ meta: AVFMappedMetadata) -> Double?
    
    func getTitle(_ meta: AVFMappedMetadata) -> String?
    
    func getArtist(_ meta: AVFMappedMetadata) -> String?
    
    func getAlbumArtist(_ meta: AVFMappedMetadata) -> String?
    
    func getAlbum(_ meta: AVFMappedMetadata) -> String?
    
    func getComposer(_ meta: AVFMappedMetadata) -> String?
    
    func getConductor(_ meta: AVFMappedMetadata) -> String?
    
    func getPerformer(_ meta: AVFMappedMetadata) -> String?
    
    func getLyricist(_ meta: AVFMappedMetadata) -> String?
    
    func getGenre(_ meta: AVFMappedMetadata) -> String?
    
    func getLyrics(_ meta: AVFMappedMetadata) -> String?
    
    func getDiscNumber(_ meta: AVFMappedMetadata) -> (number: Int?, total: Int?)?
    
    func getTrackNumber(_ meta: AVFMappedMetadata) -> (number: Int?, total: Int?)?
    
    func getArt(_ meta: AVFMappedMetadata) -> CoverArt?
    
    func getYear(_ meta: AVFMappedMetadata) -> Int?
    
    func getBPM(_ meta: AVFMappedMetadata) -> Int?

    func getGenericMetadata(_ meta: AVFMappedMetadata) -> [String: MetadataEntry]

    func getChapterTitle(_ items: [AVMetadataItem]) -> String?
}

// Default function implementations
extension AVFMetadataParser {
    
    func getAlbumArtist(_ meta: AVFMappedMetadata) -> String? {nil}
    
    func getDuration(_ meta: AVFMappedMetadata) -> Double? {nil}
    
    func getDiscNumber(_ meta: AVFMappedMetadata) -> (number: Int?, total: Int?)? {nil}
    
    func getTrackNumber(_ meta: AVFMappedMetadata) -> (number: Int?, total: Int?)? {nil}
    
    func getLyrics(_ meta: AVFMappedMetadata) -> String? {nil}
    
    func getComposer(_ meta: AVFMappedMetadata) -> String? {nil}
    
    func getConductor(_ meta: AVFMappedMetadata) -> String? {nil}
    
    func getPerformer(_ meta: AVFMappedMetadata) -> String? {nil}
    
    func getLyricist(_ meta: AVFMappedMetadata) -> String? {nil}
    
    func getYear(_ meta: AVFMappedMetadata) -> Int? {nil}
    
    func getBPM(_ meta: AVFMappedMetadata) -> Int? {nil}
    
    func getArt(_ meta: AVFMappedMetadata) -> CoverArt? {nil}
    
    func getChapterTitle(_ items: [AVMetadataItem]) -> String? {nil}
    
    func getGenericMetadata(_ meta: AVFMappedMetadata) -> [String: MetadataEntry] {[:]}
}
