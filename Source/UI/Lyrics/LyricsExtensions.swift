//
// LyricsExtensions.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation
import LyricsCore

extension Lyrics {
    
    var offset: TimeInterval {
        
        if let offsetTag = self.idTags[.offset], let theOffset = TimeInterval(offsetTag) {
            return theOffset
        }
        
        return 0
    }
    
    /// Saves lyrics to the lyrics directory with .lrcx format.
    func persistToFile(_ fileName: String) {
        
        let url = FilesAndPaths.lyricsDir.appendingPathComponent(fileName + ".lrcx")
        persistLyrics(self, to: url)
    }
    
    func maxPosition(ofLineAtIndex index: Int, maxPossiblePosition: TimeInterval) -> TimeInterval {
        
        let line = lines[index]
        
        if line.timeTagDuration > 0 {
            return line.maxPosition
        }
        
        if index < self.lastIndex {
            return lines[index + 1].position - 0.001
        }
        
        return maxPossiblePosition
    }

    /// Persists lyrics content to a file
    ///
    /// - Parameters:
    ///   - lyrics: The lyrics to save
    ///   - url: The destination URL
    private func persistLyrics(_ lyrics: Lyrics, to url: URL) {
        
        url.parentDir.createDirectory()

        do {
            try lyrics.description.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            print("Failed to write lyrics to \(url.path): \(error.localizedDescription)")
        }
    }
}

enum LyricsLineRelativePosition {
    
    case match
    case left
    case right
}

extension Track {

    /// Fetches local lyrics for this track from multiple sources in the following order:
    /// 1. Lyrics directory
    /// 2. Audio file directory
    /// 3. Embedded lyrics in the audio file
    ///
    /// - Returns: A Lyrics object if found, nil otherwise
    /// 
    func fetchLocalLyrics() -> TimedLyrics? {

        // 1. First try to find lyrics from Aural lyrics directory
        if let lyrics = loadLyricsFromDirectory(FilesAndPaths.lyricsDir) {
            return TimedLyrics(from: lyrics, for: self)
        }

        // 2. Then try to find lyrics from audio file directory
        if let lyrics = loadLyricsFromDirectory(file.parentDir) {
            return TimedLyrics(from: lyrics, for: self)
        }

        // 3. Fallback to embedded lyrics
        if let lyrics, let theLyrics = Lyrics(lyrics) {
            return TimedLyrics(from: theLyrics, for: self)
        }

        return nil
    }

    /// Loads lyrics from a specified directory by searching for .lrc or .lrcx files
    ///
    /// - Parameter directory: The directory to search for lyrics files
    /// - Returns: A Lyrics object if found and successfully loaded, nil otherwise
    ///
    private func loadLyricsFromDirectory(_ directory: URL) -> Lyrics? {
        
        if let lyricsFile = locateLyricsFile(in: directory) {
            return loadLyricsFromFile(at: lyricsFile)
        }
        
        return nil
    }

    /// Locates a lyrics file in the specified directory.
    /// Searches for both .lrc and .lrcx files with matching filename.
    ///
    /// - Parameter directory: The directory to search in
    /// - Returns: URL of the found lyrics file, nil if not found
    ///
    private func locateLyricsFile(in directory: URL) -> URL? {
        
        let possibleFiles = SupportedTypes.lyricsFileExtensions.map {
            directory.appendingPathComponent(defaultDisplayName).appendingPathExtension($0)
        }

        return possibleFiles.first {$0.exists}
    }
    
    func loadTimedLyricsFromFile(at url: URL) -> TimedLyrics? {
        
        if let lyrics = loadLyricsFromFile(at: url) {
            return TimedLyrics(from: lyrics, for: self)
        }
        
        return nil
    }

    /// Loads lyrics content from a file at the specified URL
    ///
    /// - Parameter url: The URL of the lyrics file
    /// - Returns: A Lyrics object if successfully loaded, nil otherwise
    ///
    private func loadLyricsFromFile(at url: URL) -> Lyrics? {
        
        do {
            
            let lyricsText = try String(contentsOf: url, encoding: .utf8)
            return Lyrics(lyricsText)
            
        } catch {
            
            print("Failed to read lyrics file at \(url.path): \(error.localizedDescription)")
            return nil
        }
    }
}
