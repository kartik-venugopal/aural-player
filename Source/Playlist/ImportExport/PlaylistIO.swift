//
//  PlaylistIO.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A functional contract for perform playlist file import / export I/O operations.
///
protocol PlaylistIOProtocol {
    
    // Save current playlist to an output file
    static func savePlaylist(tracks: [Track], toFile file: URL)
    
    static func loadPlaylist(fromFile playlistFile: URL) -> ImportedPlaylist?
}

///
/// A facade for performing playlist file import / export I/O operations.
///
/// Delegates to other utilities for handling of specific playlist file types, eg. M3U.
///
class PlaylistIO: PlaylistIOProtocol {
    
    static let absoluteFilePathPrefix: String = "file:///"
    
    static let stringEncodingFormats: [String.Encoding] = [.utf8, .ascii, .macOSRoman, .isoLatin1, .isoLatin2, .windowsCP1250, .windowsCP1251, .windowsCP1252, .windowsCP1253, .windowsCP1254, .unicode, .utf16, .utf16BigEndian, .utf16LittleEndian, .utf32, .utf32BigEndian, .utf32LittleEndian, .iso2022JP, .japaneseEUC, .nextstep, .nonLossyASCII, .shiftJIS, .symbol]
    
    // Save the given tracks to an output file.
    static func savePlaylist(tracks: [Track], toFile file: URL) {
        M3UPlaylistIO.savePlaylist(tracks: tracks, toFile: file)
    }
    
    // Load playlist from file into current playlist.
    static func loadPlaylist(fromFile playlistFile: URL) -> ImportedPlaylist? {
        
        let fileExtension = playlistFile.lowerCasedExtension
        
        if fileExtension.equalsOneOf(SupportedTypes.m3u, SupportedTypes.m3u8) {
            return M3UPlaylistIO.loadPlaylist(fromFile: playlistFile)
            
        } else if fileExtension == SupportedTypes.cue {
            return CueSheetIO.loadPlaylist(fromFile: playlistFile)
        }
        
        return nil
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
