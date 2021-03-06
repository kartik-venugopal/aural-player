import Foundation

protocol FFmpegMetadataParser {
    
    func mapTrack(_ meta: FFmpegMappedMetadata)
    
    func hasMetadataForTrack(_ meta: FFmpegMappedMetadata) -> Bool
    
    func getTitle(_ meta: FFmpegMappedMetadata) -> String?
    
    func getArtist(_ meta: FFmpegMappedMetadata) -> String?
    
    func getAlbumArtist(_ meta: FFmpegMappedMetadata) -> String?
    
    func getAlbum(_ meta: FFmpegMappedMetadata) -> String?
    
    func getComposer(_ meta: FFmpegMappedMetadata) -> String?
    
    func getConductor(_ meta: FFmpegMappedMetadata) -> String?
    
    func getPerformer(_ meta: FFmpegMappedMetadata) -> String?
    
    func getLyricist(_ meta: FFmpegMappedMetadata) -> String?
    
    func getGenre(_ meta: FFmpegMappedMetadata) -> String?
    
    func getLyrics(_ meta: FFmpegMappedMetadata) -> String?
    
    func getDiscNumber(_ meta: FFmpegMappedMetadata) -> (number: Int?, total: Int?)?
    
    func getTotalDiscs(_ meta: FFmpegMappedMetadata) -> Int?
    
    func getTrackNumber(_ meta: FFmpegMappedMetadata) -> (number: Int?, total: Int?)?
    
    func getTotalTracks(_ meta: FFmpegMappedMetadata) -> Int?
    
    func getYear(_ meta: FFmpegMappedMetadata) -> Int?
    
    func getDuration(_ meta: FFmpegMappedMetadata) -> Double?
    
    func getBPM(_ meta: FFmpegMappedMetadata) -> Int?
    
    func isDRMProtected(_ meta: FFmpegMappedMetadata) -> Bool?
    
    func getGenericMetadata(_ meta: FFmpegMappedMetadata) -> [String: MetadataEntry]
}

extension FFmpegMetadataParser {
    
    func getTitle(_ meta: FFmpegMappedMetadata) -> String? {nil}
    
    func getArtist(_ meta: FFmpegMappedMetadata) -> String? {nil}
    
    func getAlbumArtist(_ meta: FFmpegMappedMetadata) -> String? {nil}
    
    func getAlbum(_ meta: FFmpegMappedMetadata) -> String? {nil}
    
    func getComposer(_ meta: FFmpegMappedMetadata) -> String? {nil}
    
    func getConductor(_ meta: FFmpegMappedMetadata) -> String? {nil}
    
    func getPerformer(_ meta: FFmpegMappedMetadata) -> String? {nil}
    
    func getLyricist(_ meta: FFmpegMappedMetadata) -> String? {nil}
    
    func getGenre(_ meta: FFmpegMappedMetadata) -> String? {nil}
    
    func getLyrics(_ meta: FFmpegMappedMetadata) -> String? {nil}
    
    func getYear(_ meta: FFmpegMappedMetadata) -> Int? {nil}
    
    func getBPM(_ meta: FFmpegMappedMetadata) -> Int? {nil}
    
    func getDiscNumber(_ meta: FFmpegMappedMetadata) -> (number: Int?, total: Int?)? {nil}
    
    func getTotalDiscs(_ meta: FFmpegMappedMetadata) -> Int? {nil}
    
    func getTrackNumber(_ meta: FFmpegMappedMetadata) -> (number: Int?, total: Int?)? {nil}
    
    func getTotalTracks(_ meta: FFmpegMappedMetadata) -> Int? {nil}
 
    func getDuration(_ meta: FFmpegMappedMetadata) -> Double? {nil}
    
    func isDRMProtected(_ meta: FFmpegMappedMetadata) -> Bool? {nil}
    
    func getGenericMetadata(_ meta: FFmpegMappedMetadata) -> [String: MetadataEntry] {[:]}
}
