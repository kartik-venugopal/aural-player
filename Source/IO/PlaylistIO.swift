import Foundation

/*
    Performs I/O of playlists in the M3U/M3U8 format
*/
class PlaylistIO {
    
    private static let m3uHeader: String = "#EXTM3U"
    private static let m3uInfoPrefix: String = "#EXTINF:"
    private static let absoluteFilePathPrefix: String = "file:///"
    
    static var playlist: PlaylistAccessorProtocol!
    
    static func initialize(_ playlist: PlaylistAccessorProtocol) {
        PlaylistIO.playlist = playlist
    }
    
    // Save current playlist to an output file
    static func savePlaylist(_ file: URL) {
        
        let tracks = playlist.tracks
        
        var contents: String = m3uHeader + "\n"
        
        // Buffer the output
        for track in tracks {
            
            // EXTINF line consists of the prefix, followed by duration and track name (without extension)
            let extInfo = String(format: "%@%d,%@", m3uInfoPrefix, Int(round(track.duration)), track.conciseDisplayName)
            contents.append(extInfo + "\n")
            
            // Compute a relative path for this track, relative to the playlist folder.
            // For example, if playlist = /A/B/C/D.m3u, and trackFile = /A/E.mp3, then the relative path = ../../../E.mp3
            let relativePath = FileSystemUtils.relativePath(file, track.file)
            contents.append(relativePath + "\n")
        }
        
        // Write to output file
        do {
            try contents.write(to: file, atomically: false, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            NSLog("Error writing playlist file '%@': %@", file.path, error.description)
        }
    }
    
    // Load playlist from file into current playlist. Handles varying M3U formats.
    static func loadPlaylist(_ file: URL) -> SavedPlaylist? {
        
        do {
            let fileContents = try String(contentsOfFile: file.path)
            let lines = fileContents.components(separatedBy: .newlines)
            
            var tracks: [URL] = [URL]()
            
            for line in lines {
                
                if line.contains(m3uHeader) {
                    // IGNORE EXTM3U header
                } else if line.contains(m3uInfoPrefix) {
                    // IGNORE EXTINF (duration and display name are recomputed anyway)
                } else {
                    
                    // Line contains track path
                    if (!StringUtils.isStringEmpty(line)) {
                        
                        // Convert Windows paths to UNIX paths (this will not work for absolute Windows paths like "C:\...")
                        let trackFilePath = line.replacingOccurrences(of: "\\", with: "/")
                        
                        var url: URL
                        if (trackFilePath.hasPrefix("/")) {
                            
                            // Absolute path
                            url = URL(fileURLWithPath: trackFilePath)
                            
                        } else if (trackFilePath.hasPrefix(absoluteFilePathPrefix)) {
                            
                            // Absolute path with prefix. Remove the prefix
                            let cleanURL = trackFilePath.replacingOccurrences(of: absoluteFilePathPrefix, with: "/")
                            url = URL(fileURLWithPath: cleanURL)
                            
                        } else {
                            
                            // Relative path
                            let playlistFolder = file.deletingLastPathComponent()
                            let relativePath = playlistFolder.path + "/" + trackFilePath
                            url = URL(fileURLWithPath: relativePath)
                        }
                        
                        tracks.append(url)
                    }
                }
            }
            
            return SavedPlaylist(file: file, tracks: tracks)
            
        } catch let error as NSError {
            NSLog("Error reading playlist file '%@': %@", file.path, error.description)
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
