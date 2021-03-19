import Cocoa
import AVFoundation

/*
    Utility for reading and categorizing track metadata
 */
class MetadataUtils {

    private static let playlist: PlaylistDelegateProtocol = ObjectGraph.playlistDelegate
    
    private static let avAssetReader: AVAssetReader = AVAssetReader()
    private static let ffMpegReader: FFMpegReader = FFMpegReader()
    
    // Loads the required display metadata (artist/title/art) for a track
    static func loadPrimaryMetadata(_ track: Track) {
        
        let metadata: PrimaryMetadata = track.metadataNativelySupported ? avAssetReader.getPrimaryMetadata(track) : ffMpegReader.getPrimaryMetadata(track)
        track.setPrimaryMetadata(metadata.artist, metadata.title, metadata.album, metadata.genre, metadata.duration)
    }
    
    static func loadSecondaryMetadata(_ track: Track) {
        
        let metadata: SecondaryMetadata = track.metadataNativelySupported ? avAssetReader.getSecondaryMetadata(track) : ffMpegReader.getSecondaryMetadata(track)
        track.setSecondaryMetadata(metadata.discNum, metadata.totalDiscs, metadata.trackNum, metadata.totalTracks, metadata.lyrics)
    }
    
    static func loadArt(_ track: Track) {
        
        var art: CoverArt? = nil
        
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
        
        track.metadata = isFileMetadataNativelySupported(track.file) ? avAssetReader.getAllMetadata(track) : ffMpegReader.getAllMetadata(track)
    }
    
    static func durationForFile(_ file: URL) -> Double {
        return isFileMetadataNativelySupported(file) ? avAssetReader.getDurationForFile(file) : ffMpegReader.getDurationForFile(file)
    }
    
    static func artForFile(_ file: URL) -> CoverArt? {
        
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
    case audioToolbox
    case wma
    case vorbis
    case ape
    case other
    
    // Smaller the number, higher the sort order
    var sortOrder: Int {
        
        switch self {
            
        case .common:   return 0
            
        case .iTunes:  return 1
            
        case .id3:  return 2
            
        case .audioToolbox: return 3
            
        case .wma:  return 4
            
        case .vorbis:  return 5
            
        case .ape:  return 6
            
        case .other:    return 7
            
        }
    }
}
