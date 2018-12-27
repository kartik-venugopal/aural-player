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
    }
    
    static func loadSecondaryMetadata(_ track: Track) {
        
        let metadata: SecondaryMetadata = track.metadataNativelySupported ? avAssetReader.getSecondaryMetadata(track) : ffMpegReader.getSecondaryMetadata(track)
        track.setSecondaryMetadata(metadata.discNum, metadata.trackNum)
    }
    
    static func loadArt(_ track: Track) {
        
        var art: NSImage? = nil
        
        let cachedArt = AlbumArtCache.forFile(track.file)
        
        if let cachedArtImg = cachedArt.art {
            
            art = cachedArtImg
            
        } else if !cachedArt.fileHasNoArt {
            
            // File may have art, need to read it
            art = track.metadataNativelySupported ? avAssetReader.getArt(track) : ffMpegReader.getArt(track)
            AlbumArtCache.addEntry(track.file, art)
        }
        
        track.displayInfo.art = art
    }
    
    // Loads all available metadata for a track
    static func loadAllMetadata(_ track: Track) {
        
        let metadata = isFileMetadataNativelySupported(track.file) ? avAssetReader.getAllMetadata(track) : ffMpegReader.getAllMetadata(track)
        track.metadata = metadata
    }
    
    static func durationForFile(_ file: URL) -> Double {
        return isFileMetadataNativelySupported(file) ? avAssetReader.getDurationForFile(file) : ffMpegReader.getDurationForFile(file)
    }
    
    static func artForFile(_ file: URL) -> NSImage? {
        
        // If playlist has this track, get art from there
        if let track = playlist.findFile(file)?.track {
            
            if track.displayInfo.art == nil {
                loadArt(track)
            }
            
            return track.displayInfo.art
        }
        
        let cachedArt = AlbumArtCache.forFile(file)
        
        if let cachedArtImg = cachedArt.art {
            
            return cachedArtImg
            
        } else if !cachedArt.fileHasNoArt {
            
            // File may have art, need to read it
            let art = isFileMetadataNativelySupported(file) ? avAssetReader.getArt(file) : ffMpegReader.getArt(file)
            AlbumArtCache.addEntry(file, art)
            
            return art
        }
        
        return nil
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
