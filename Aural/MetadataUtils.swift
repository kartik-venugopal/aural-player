import Cocoa
import AVFoundation

/*
    Utility for reading and categorizing track metadata
 */
class MetadataUtils {

    private static let playlist: PlaylistDelegateProtocol = ObjectGraph.playlistDelegate
    
    private static let avAssetReader: AVAssetReader = AVAssetReader()
    
    private static let secondaryMetadataLoadingQueue: OperationQueue = {
        
        let q = OperationQueue()
        
        q.maxConcurrentOperationCount = 10
        q.underlyingQueue = DispatchQueue.global(qos: .background)
        
        return q
    }()
    
    // Loads the required display metadata (artist/title/art) for a track
    static func loadPrimaryMetadata(_ track: Track) {
        
        if track.metadataNativelySupported {
            
            let metadata = avAssetReader.getPrimaryMetadata(track)
            track.setPrimaryMetadata(metadata.artist, metadata.title, metadata.album, metadata.genre, metadata.duration)

        } else {
            
        }
    }
    
    static func loadSecondaryMetadata(_ track: Track) {
        
        if track.metadataNativelySupported {
            
            let metadata = avAssetReader.getSecondaryMetadata(track)
            track.setSecondaryMetadata(metadata.art, metadata.discNum, metadata.trackNum)
            
        } else {
            
        }
    }
    
    // Loads all available metadata for a track
    static func loadAllMetadata(_ track: Track) {
        
        if !isFileMetadataNativelySupported(track.file) {
            
           
            
        } else {
            
            
        }
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVMetadataKey(_ input: AVMetadataKey) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToAVMetadataIdentifier(_ input: String) -> AVMetadataIdentifier {
	return AVMetadataIdentifier(rawValue: input)
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVMetadataFormatArray(_ input: [AVMetadataFormat]) -> [String] {
	return input.map { key in key.rawValue }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVMetadataFormat(_ input: AVMetadataFormat) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToAVMetadataFormat(_ input: String) -> AVMetadataFormat {
	return AVMetadataFormat(rawValue: input)
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromOptionalAVMetadataKey(_ input: AVMetadataKey?) -> String? {
	guard let input = input else { return nil }
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToAVMetadataKeySpace(_ input: String) -> AVMetadataKeySpace {
	return AVMetadataKeySpace(rawValue: input)
}
