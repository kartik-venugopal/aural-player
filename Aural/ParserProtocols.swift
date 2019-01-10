import Cocoa
import AVFoundation

/*
    Contract for a metadata specification
 */
protocol AVAssetParser {
    
    func mapTrack(_ track: Track, _ mapForTrack: AVAssetMetadata)
    
    func getDuration(_ mapForTrack: AVAssetMetadata) -> Double?
    
    func getTitle(_ mapForTrack: AVAssetMetadata) -> String?
    
    func getArtist(_ mapForTrack: AVAssetMetadata) -> String?
    
    func getAlbum(_ mapForTrack: AVAssetMetadata) -> String?
    
    func getGenre(_ mapForTrack: AVAssetMetadata) -> String?
    
    func getLyrics(_ mapForTrack: AVAssetMetadata) -> String?
    
    func getDiscNumber(_ mapForTrack: AVAssetMetadata) -> (number: Int?, total: Int?)?
    
    func getTrackNumber(_ mapForTrack: AVAssetMetadata) -> (number: Int?, total: Int?)?
    
    func getArt(_ mapForTrack: AVAssetMetadata) -> NSImage?
    
    func getArt(_ asset: AVURLAsset) -> NSImage?
    
    func getGenericMetadata(_ mapForTrack: AVAssetMetadata) -> [String: MetadataEntry]
}

protocol FFMpegMetadataParser {
    
    func mapTrack(_ mapForTrack: LibAVMetadata)
    
    func getTitle(_ mapForTrack: LibAVMetadata) -> String?
    
    func getArtist(_ mapForTrack: LibAVMetadata) -> String?
    
    func getAlbum(_ mapForTrack: LibAVMetadata) -> String?
    
    func getGenre(_ mapForTrack: LibAVMetadata) -> String?
    
    func getLyrics(_ mapForTrack: LibAVMetadata) -> String?
    
    func getDiscNumber(_ mapForTrack: LibAVMetadata) -> (number: Int?, total: Int?)?
    
    func getTotalDiscs(_ mapForTrack: LibAVMetadata) -> Int?
    
    func getTrackNumber(_ mapForTrack: LibAVMetadata) -> (number: Int?, total: Int?)?
    
    func getTotalTracks(_ mapForTrack: LibAVMetadata) -> Int?
    
    func getGenericMetadata(_ mapForTrack: LibAVMetadata) -> [String: MetadataEntry]
}
