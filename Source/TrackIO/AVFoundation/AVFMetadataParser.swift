import Cocoa
import AVFoundation

protocol AVFMetadataParser {
    
    var keySpace: AVMetadataKeySpace {get}
    
    func getDuration(_ meta: AVFMetadata) -> Double?
    
    func getTitle(_ meta: AVFMetadata) -> String?
    
    func getArtist(_ meta: AVFMetadata) -> String?
    
    func getAlbumArtist(_ meta: AVFMetadata) -> String?
    
    func getAlbum(_ meta: AVFMetadata) -> String?
    
    func getComposer(_ meta: AVFMetadata) -> String?
    
    func getConductor(_ meta: AVFMetadata) -> String?
    
    func getPerformer(_ meta: AVFMetadata) -> String?
    
    func getLyricist(_ meta: AVFMetadata) -> String?
    
    func getGenre(_ meta: AVFMetadata) -> String?
    
    func getLyrics(_ meta: AVFMetadata) -> String?
    
    func getDiscNumber(_ meta: AVFMetadata) -> (number: Int?, total: Int?)?
    
    func getTrackNumber(_ meta: AVFMetadata) -> (number: Int?, total: Int?)?
    
    func getArt(_ meta: AVFMetadata) -> NSImage?
    
    func getYear(_ meta: AVFMetadata) -> Int?
    
    func getBPM(_ meta: AVFMetadata) -> Int?

    func getGenericMetadata(_ meta: AVFMetadata) -> [String: MetadataEntry]
//
//    // ----------- Chapter-related functions
//
    func getChapterTitle(_ items: [AVMetadataItem]) -> String?
}

// Default function implementations
extension AVFMetadataParser {
    
    func getAlbumArtist(_ meta: AVFMetadata) -> String? {nil}
    
    func getDuration(_ meta: AVFMetadata) -> Double? {nil}
    
    func getDiscNumber(_ meta: AVFMetadata) -> (number: Int?, total: Int?)? {nil}
    
    func getTrackNumber(_ meta: AVFMetadata) -> (number: Int?, total: Int?)? {nil}
    
    func getLyrics(_ meta: AVFMetadata) -> String? {nil}
    
    func getComposer(_ meta: AVFMetadata) -> String? {nil}
    
    func getConductor(_ meta: AVFMetadata) -> String? {nil}
    
    func getPerformer(_ meta: AVFMetadata) -> String? {nil}
    
    func getLyricist(_ meta: AVFMetadata) -> String? {nil}
    
    func getYear(_ meta: AVFMetadata) -> Int? {nil}
    
    func getBPM(_ meta: AVFMetadata) -> Int? {nil}
    
    func getArt(_ meta: AVFMetadata) -> NSImage? {nil}
    
    func getChapterTitle(_ items: [AVMetadataItem]) -> String? {nil}
    
    func getGenericMetadata(_ meta: AVFMetadata) -> [String: MetadataEntry] {[:]}
}
