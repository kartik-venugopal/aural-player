import Cocoa
import AVFoundation

/*
    Utility for reading and categorizing track metadata
 */
class MetadataUtils {

    private static let playlist: PlaylistDelegateProtocol = ObjectGraph.playlistDelegate
    
    private static let avAssetReader: AVAssetReader = AVAssetReader()
    private static let ffMpegReader: FFMpegReader = FFMpegReader()
    
    private static let secondaryMetadataLoadingQueue: OperationQueue = {
        
        let q = OperationQueue()
        
        q.maxConcurrentOperationCount = 10
        q.underlyingQueue = DispatchQueue.global(qos: .background)
        
        return q
    }()
    
    // Loads the required display metadata (artist/title/art) for a track
    static func loadPrimaryMetadata(_ track: Track) {
        
        let metadata: PrimaryMetadata = track.metadataNativelySupported ? avAssetReader.getPrimaryMetadata(track) : ffMpegReader.getPrimaryMetadata(track)
        track.setPrimaryMetadata(metadata.artist, metadata.title, metadata.album, metadata.genre, metadata.duration)
        
        track.lazyLoadingInfo.primaryMetadataLoaded = true
    }
    
    static func loadSecondaryMetadata(_ track: Track) {
        
        let metadata: SecondaryMetadata = track.metadataNativelySupported ? avAssetReader.getSecondaryMetadata(track) : ffMpegReader.getSecondaryMetadata(track)
        track.setSecondaryMetadata(metadata.art, metadata.discNum, metadata.trackNum)
        
        track.lazyLoadingInfo.secondaryMetadataLoaded = true
    }
    
    static func loadArt(_ track: Track) {
        
        let art = track.metadataNativelySupported ? avAssetReader.getArt(track) : ffMpegReader.getArt(track)
        track.displayInfo.art = art
    }
    
    // Loads all available metadata for a track
    static func loadAllMetadata(_ track: Track) {
        
        // TODO
        
        if !isFileMetadataNativelySupported(track.file) {
        } else {
        }
        
        track.lazyLoadingInfo.allMetadataLoaded = true
    }
    
    // Computes a user-friendly key, given a format-specific key, if it has a recognized format (ID3/iTunes)
    static func formattedKey(_ entry: MetadataEntry) -> String {
        
        // Use the metadata spec to format the key
        switch entry.type {
        
        // Common space keys (camel cased) need to be split up into separate words
        case .common:   return StringUtils.splitCamelCaseWord(entry.key, true)
            
        case .id3:  return ID3Spec.readableKey(entry.key) ?? entry.key
            
        case .iTunes: return ITunesSpec.readableKey(entry.key) ?? entry.key
            
        // Unrecognized entry type, return key as is
        case .other: return entry.key
            
        }
    }
    
//    // Loads art for a given file (used by bookmarks)
//    static func loadArtworkForFile(_ file: URL) -> NSImage? {
//
//        if let track = playlist.findFile(file) {
//            return track.track.displayInfo.art
//        }
//
//        if !isFileMetadataNativelySupported(file) {
//
//            // TODO: Need to make this thread-safe and efficient
////            return FFMpegWrapper.getArtwork(file)
//            return nil
//        } else {
//            return getArtwork(AVURLAsset(url: file, options: nil))
//        }
//    }
    
    static func isFileMetadataNativelySupported(_ file: URL) -> Bool {
        
        let ext = file.pathExtension.lowercased()
        return AppConstants.SupportedTypes.nativeAudioExtensions.contains(ext) && ext != "flac"
    }
}

// Denotes the type (format) of a metadata entry
enum MetadataType: String {
    
    case common
    case iTunes
    case id3
    case other
}
