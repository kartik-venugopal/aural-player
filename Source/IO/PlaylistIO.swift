import Foundation

/*
    Performs I/O of playlists in the M3U/M3U8 format
*/
class PlaylistIO {
    
    private static let m3uHeader: String = "#EXTM3U"
    private static let m3uInfoPrefix: String = "#EXTINF:"
    private static let absoluteFilePathPrefix: String = "file:///"
    
    private static let stringEncodingFormats: [String.Encoding] = [.utf8, .ascii, .macOSRoman, .isoLatin1, .isoLatin2, .windowsCP1250, .windowsCP1251, .windowsCP1252, .windowsCP1253, .windowsCP1254, .unicode, .utf16, .utf16BigEndian, .utf16LittleEndian, .utf32, .utf32BigEndian, .utf32LittleEndian, .iso2022JP, .japaneseEUC, .nextstep, .nonLossyASCII, .shiftJIS, .symbol]
    
    static var playlist: PlaylistAccessorProtocol!
    
    static func initialize(_ playlist: PlaylistAccessorProtocol) {
        PlaylistIO.playlist = playlist
    }
    
    // Save current playlist to an output file
    static func savePlaylist(_ file: URL) {
        
        var contents: String = m3uHeader + "\n"
        
        // Buffer the output
        for track in playlist.tracks {
            
            // EXTINF line consists of the prefix, followed by duration and track name (without extension)
            let extInfo = String(format: "%@%d,%@", m3uInfoPrefix, roundedInt(track.duration), track.conciseDisplayName)
            contents.append(extInfo + "\n")
            
            // Compute a relative path for this track, relative to the playlist folder.
            // For example, if playlist = /A/B/C/D.m3u, and trackFile = /A/E.mp3, then the relative path = ../../../E.mp3
            let relativePath = FileSystemUtils.relativePath(file, track.file)
            contents.append(relativePath + "\n")
        }
        
        // Write to output file
        do {
            
            let encodeAsUTF8: Bool = file.pathExtension.lowercased() == AppConstants.SupportedTypes.m3u8
            
            try contents.write(to: file, atomically: true,
                               encoding: encodeAsUTF8 ? String.Encoding.utf8 : String.Encoding.macOSRoman)
            
        } catch let error as NSError {
            NSLog("Error writing playlist file '%@': %@", file.path, error.description)
        }
    }
    
    private static func readFileAsString(_ file: URL) -> String? {
        
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
        
        guard let fileContents: String = readFileAsString(playlistFile) else {return nil}
        
        let lines = fileContents.components(separatedBy: .newlines)
        
        var tracks: [URL] = []
        
        for line in lines {
            
            if line.contains(m3uHeader) {
                // IGNORE EXTM3U header
                
            } else if line.contains(m3uInfoPrefix) {
                // IGNORE EXTINF (duration and display name are recomputed anyway)
                
            } else {
                
                // Line contains track path
                if !StringUtils.isStringEmpty(line) {
                    
                    // Convert Windows paths to UNIX paths (this will not work for absolute Windows paths like "C:\...")
                    let trackFilePath: String = line.replacingOccurrences(of: "\\", with: "/")
                    
                    // If a scheme is defined, and it doesn't point to a local file, ignore the file.
                    if let scheme = URL(string: trackFilePath)?.scheme, scheme != "file" {
                        continue
                    }
                    
                    var url: URL
                    if trackFilePath.hasPrefix("/") {
                        
                        // Absolute path
                        url = URL(fileURLWithPath: trackFilePath)
                        
                    } else if trackFilePath.hasPrefix(absoluteFilePathPrefix) {
                        
                        // Absolute path with prefix. Remove the prefix
                        let cleanURLPath: String = trackFilePath.replacingOccurrences(of: absoluteFilePathPrefix, with: "/")
                        url = URL(fileURLWithPath: cleanURLPath)
                        
                    } else {
                        
                        // Relative path
                        let playlistFolder: URL = playlistFile.deletingLastPathComponent()
                        url = playlistFolder.appendingPathComponent(trackFilePath, isDirectory: false)
                    }
                    
                    tracks.append(url)
                }
            }
        }
        
        return SavedPlaylist(file: playlistFile, tracks: tracks)
    }
}

// Represents a persistent playlist (as opposed to a playing playlist) stored in a m3u file.
struct SavedPlaylist {

    // The filesystem location of the playlist file referenced by this object
    let file: URL
    
    // URLs of tracks in this playlist
    let tracks: [URL]
}
