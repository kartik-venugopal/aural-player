import Foundation

protocol FFmpegMetadataParser {
    
    func mapTrack(_ meta: FFmpegMappedMetadata)
    
    func hasEssentialMetadataForTrack(_ meta: FFmpegMappedMetadata) -> Bool
    
    func hasGenericMetadataForTrack(_ meta: FFmpegMappedMetadata) -> Bool
    
    func getTitle(_ meta: FFmpegMappedMetadata) -> String?
    
    func getArtist(_ meta: FFmpegMappedMetadata) -> String?
    
    func getAlbum(_ meta: FFmpegMappedMetadata) -> String?
    
    func getGenre(_ meta: FFmpegMappedMetadata) -> String?
    
    func getLyrics(_ meta: FFmpegMappedMetadata) -> String?
    
    func getDiscNumber(_ meta: FFmpegMappedMetadata) -> (number: Int?, total: Int?)?
    
    func getTotalDiscs(_ meta: FFmpegMappedMetadata) -> Int?
    
    func getTrackNumber(_ meta: FFmpegMappedMetadata) -> (number: Int?, total: Int?)?
    
    func getTotalTracks(_ meta: FFmpegMappedMetadata) -> Int?
    
    func getDuration(_ meta: FFmpegMappedMetadata) -> Double?
    
    func isDRMProtected(_ meta: FFmpegMappedMetadata) -> Bool?
    
    func getGenericMetadata(_ meta: FFmpegMappedMetadata) -> [String: MetadataEntry]
}

extension FFmpegMetadataParser {
    
    func getTitle(_ meta: FFmpegMappedMetadata) -> String? {nil}
    
    func getArtist(_ meta: FFmpegMappedMetadata) -> String? {nil}
    
    func getAlbum(_ meta: FFmpegMappedMetadata) -> String? {nil}
    
    func getGenre(_ meta: FFmpegMappedMetadata) -> String? {nil}
    
    func getLyrics(_ meta: FFmpegMappedMetadata) -> String? {nil}
    
    func getDiscNumber(_ meta: FFmpegMappedMetadata) -> (number: Int?, total: Int?)? {nil}
    
    func getTotalDiscs(_ meta: FFmpegMappedMetadata) -> Int? {nil}
    
    func getTrackNumber(_ meta: FFmpegMappedMetadata) -> (number: Int?, total: Int?)? {nil}
    
    func getTotalTracks(_ meta: FFmpegMappedMetadata) -> Int? {nil}
 
    func getDuration(_ meta: FFmpegMappedMetadata) -> Double? {nil}
    
    func isDRMProtected(_ meta: FFmpegMappedMetadata) -> Bool? {nil}
    
    func getGenericMetadata(_ meta: FFmpegMappedMetadata) -> [String: MetadataEntry] {[:]}
}
