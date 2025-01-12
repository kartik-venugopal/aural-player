//
//  M3UPlaylistIO.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Performs M3U / M3U8 playlist file import / export I/O operations.
///
class M3UPlaylistIO: PlaylistIOProtocol {
    
    private static let header: String = "#EXTM3U"
    private static let infoPrefix: String = "#EXTINF:"
    
    // Save current playlist to an output file
    static func savePlaylist(tracks: [Track], toFile file: URL) {
        
        var contents: String = header + "\n"
        
        // Buffer the output
        for track in tracks {
            
            // EXTINF line consists of the prefix, followed by duration and track name (without extension)
            let extInfo = String(format: "%@%d,%@", infoPrefix, track.duration.roundedInt, track.displayName)
            contents.append(extInfo + "\n")
            
            // Compute a relative path for this track, relative to the playlist folder.
            // For example, if playlist = /A/B/C/D.m3u, and trackFile = /A/E.mp3, then the relative path = ../../E.mp3
            let relativePath = track.file.path(relativeTo: file)
            contents.append(relativePath + "\n")
        }
        
        // Write to output file
        do {
            
            try contents.write(to: file, atomically: true, encoding: String.Encoding.utf8)
            
        } catch let error as NSError {
            NSLog("Error writing playlist file '%@': %@", file.path, error.description)
        }
    }
    
    // Load playlist from file into current playlist. Handles varying M3U formats.
    static func loadPlaylist(fromFile playlistFile: URL) -> FileSystemPlaylist? {
        
        guard let fileContents: String = PlaylistIO.readFileAsString(playlistFile) else {return nil}
        
        let lines = fileContents.components(separatedBy: .newlines)
        
        var tracks: [URL] = []
        
        for line in lines {
            
            if line.contains(header) {
                // IGNORE EXTM3U header
                
            } else if line.contains(infoPrefix) {
                // IGNORE EXTINF (duration and display name are recomputed anyway)
                
            } else {
                
                // Line contains track path
                guard !String.isEmpty(line) else {continue}
                
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
                    
                } else if trackFilePath.hasPrefix(PlaylistIO.absoluteFilePathPrefix) {
                    
                    // Absolute path with prefix. Remove the prefix
                    let cleanURLPath: String = trackFilePath.replacingOccurrences(of: PlaylistIO.absoluteFilePathPrefix, with: "/")
                    url = URL(fileURLWithPath: cleanURLPath)
                    
                } else {
                    
                    // Relative path
                    let playlistFolder: URL = playlistFile.deletingLastPathComponent()
                    url = playlistFolder.appendingPathComponent(trackFilePath, isDirectory: false)
                }
                
                let resolvedURL = url.resolvedURL
                
                guard resolvedURL.exists else {
                    
                    NSLog("Error while parsing M3U Playlist '\(playlistFile.lastPathComponent)': File not found - '\(resolvedURL.path)'")
                    continue
                }
                
                guard resolvedURL.isSupportedAudioFile else {
                    
                    NSLog("Error while parsing M3U Playlist '\(playlistFile.lastPathComponent)': File not supported - '\(resolvedURL.path)'")
                    continue
                }
                
                if resolvedURL.exists && resolvedURL.isSupportedAudioFile {
                    tracks.append(resolvedURL)
                }
            }
        }
        
        return FileSystemPlaylist(file: playlistFile, tracks: tracks.map {FileSystemPlaylistTrack(file: $0, cueSheetMetadata: nil)})
    }
}
