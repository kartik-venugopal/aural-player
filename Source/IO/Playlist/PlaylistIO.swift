import Foundation

protocol PlaylistIOProtocol {
    
    // Save current playlist to an output file
    static func savePlaylist(_ file: URL)
    
    static func loadPlaylist(_ playlistFile: URL) -> SavedPlaylist?
}

// Facade for all importing/exporting of playlist file formats (e.g. M3U)
class PlaylistIO: PlaylistIOProtocol {
    
    static let absoluteFilePathPrefix: String = "file:///"
    
    static let stringEncodingFormats: [String.Encoding] = [.utf8, .ascii, .macOSRoman, .isoLatin1, .isoLatin2, .windowsCP1250, .windowsCP1251, .windowsCP1252, .windowsCP1253, .windowsCP1254, .unicode, .utf16, .utf16BigEndian, .utf16LittleEndian, .utf32, .utf32BigEndian, .utf32LittleEndian, .iso2022JP, .japaneseEUC, .nextstep, .nonLossyASCII, .shiftJIS, .symbol]
    
    static func initialize(_ playlist: PlaylistAccessorProtocol) {
        M3UPlaylistIO.initialize(playlist)
    }
    
    // Save current playlist to an output file
    static func savePlaylist(_ file: URL) {
        M3UPlaylistIO.savePlaylist(file)
    }
    
    // Load playlist from file into current playlist.
    static func loadPlaylist(_ playlistFile: URL) -> SavedPlaylist? {
        return M3UPlaylistIO.loadPlaylist(playlistFile)
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
}

// Represents a persistent playlist (as opposed to a playing playlist) stored in a m3u file.
struct SavedPlaylist {

    // The filesystem location of the playlist file referenced by this object
    let file: URL
    
    // URLs of tracks in this playlist
    let tracks: [URL]
}
