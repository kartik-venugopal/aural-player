import Foundation

protocol PlaylistIOProtocol {
    
    // Save current playlist to an output file
    static func savePlaylist(_ file: URL)
    
    static func loadPlaylist(_ playlistFile: URL) -> SavedPlaylist?
}

class PlaylistIO: PlaylistIOProtocol {
    
    static let absoluteFilePathPrefix: String = "file:///"
    
    static let stringEncodingFormats: [String.Encoding] = [.utf8, .ascii, .macOSRoman, .isoLatin1, .isoLatin2, .windowsCP1250, .windowsCP1251, .windowsCP1252, .windowsCP1253, .windowsCP1254, .unicode, .utf16, .utf16BigEndian, .utf16LittleEndian, .utf32, .utf32BigEndian, .utf32LittleEndian, .iso2022JP, .japaneseEUC, .nextstep, .nonLossyASCII, .shiftJIS, .symbol]
    
    static var playlist: PlaylistAccessorProtocol!
    
    static func initialize(_ playlist: PlaylistAccessorProtocol) {
        PlaylistIO.playlist = playlist
    }
    
    // Save current playlist to an output file
    static func savePlaylist(_ file: URL) {
        
        switch file.pathExtension.lowercased() {
            
        case AppConstants.SupportedTypes.m3u, AppConstants.SupportedTypes.m3u8:
            
            M3UPlaylistIO.savePlaylist(file)
            
        default:
            
            return
        }
    }
    
    static func readFileAsString(_ file: URL) -> String? {
        
        for encoding in stringEncodingFormats {

            do {
                return try String(contentsOf: file, encoding: encoding)
            } catch {}
        }
        
        NSLog("Error reading playlist file '%@'. Unable to decode. Check file encoding.", file.path)
        return nil
    }
    
    // Load playlist from file into current playlist. Handles varying M3U formats.
    static func loadPlaylist(_ playlistFile: URL) -> SavedPlaylist? {
        
        switch playlistFile.pathExtension.lowercased() {
            
        case AppConstants.SupportedTypes.m3u, AppConstants.SupportedTypes.m3u8:
            
            return M3UPlaylistIO.loadPlaylist(playlistFile)
            
        default:
            
            return nil
        }
    }
}

// Represents a persistent playlist (as opposed to a playing playlist) stored in a m3u file.
struct SavedPlaylist {

    // The filesystem location of the playlist file referenced by this object
    let file: URL
    
    // URLs of tracks in this playlist
    let tracks: [URL]
}
