//
// TimedLyricsExtensions.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation
import LyricsCore

typealias TimedLyrics = LyricsCore.Lyrics
typealias TimedLyricsLine = LyricsCore.LyricsLine

extension TimedLyrics {
    
    var offset: TimeInterval {
        
        if let offsetTag = self.idTags[.offset], let theOffset = TimeInterval(offsetTag) {
            return theOffset
        }
        
        return 0
    }
    
    func currentLine(at position: TimeInterval, ofTrack track: Track) -> Int? {
        
        var left = 0
        var right = lines.count - 1

        while left <= right {
            
            let mid = (left + right) / 2
            
            switch relativePosition(ofLineAtIndex: mid, to: position, forTrack: track) {
                
            case .match:
                return mid
                
            case .left:
                left = mid + 1
                
            case .right:
                right = mid - 1
            }
        }
        
        return nil
    }
    
    /// Saves lyrics to the lyrics directory with .lrcx format.
    func persistToFile(_ fileName: String) {
        
        let url = FilesAndPaths.lyricsDir.appendingPathComponent(fileName + ".lrcx")
        persistLyrics(self, to: url)
    }

    /// Persists lyrics content to a file
    ///
    /// - Parameters:
    ///   - lyrics: The lyrics to save
    ///   - url: The destination URL
    private func persistLyrics(_ lyrics: TimedLyrics, to url: URL) {
        
        url.parentDir.createDirectory()

        do {
            try lyrics.description.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            print("Failed to write lyrics to \(url.path): \(error.localizedDescription)")
        }
    }
    
    fileprivate func relativePosition(ofLineAtIndex index: Int, to target: TimeInterval, forTrack track: Track) -> TimedLyricsLineRelativePosition {
        
        let line = lines[index]
        
        if target < line.position {
            return .right
        }
        
        if target > self.maxPosition(ofLineAtIndex: index, forTrack: track) {
            return .left
        }
        
        return .match
    }
    
    func isLineCurrent(atIndex index: Int, atPosition target: TimeInterval, ofTrack track: Track) -> Bool {
        
        let line = lines[index]
        return target >= line.position && target <= self.maxPosition(ofLineAtIndex: index, forTrack: track)
    }
    
    fileprivate func maxPosition(ofLineAtIndex index: Int, forTrack track: Track) -> TimeInterval {
        
        let line = lines[index]
        
        if line.timeTagDuration > 0 {
            return line.maxPosition
        }
        
        if index < self.lastIndex {
            return lines[index + 1].position - 0.001
        }
        
        return track.duration - 0.001
    }
}

fileprivate enum TimedLyricsLineRelativePosition {
    
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
    func fetchLocalTimedLyrics() -> TimedLyrics? {

        // 1. First try to find lyrics from Aural lyrics directory
        if let lyrics = loadTimedLyricsFromDirectory(FilesAndPaths.lyricsDir) {
            return lyrics
        }

        // 2. Then try to find lyrics from audio file directory
        if let lyrics = loadTimedLyricsFromDirectory(file.deletingLastPathComponent()) {
            return lyrics
        }

        // 3. Fallback to embedded lyrics
        if let lyrics {
            return Lyrics(lyrics)
        }

        return nil
    }

    /// Loads lyrics from a specified directory by searching for .lrc or .lrcx files
    ///
    /// - Parameter directory: The directory to search for lyrics files
    /// - Returns: A Lyrics object if found and successfully loaded, nil otherwise
    private func loadTimedLyricsFromDirectory(_ directory: URL) -> TimedLyrics? {
        
        if let lyricsFile = locateTimedLyricsFile(in: directory) {
            return loadTimedLyricsFromFile(at: lyricsFile)
        }
        
        return nil
    }

    /// Locates a lyrics file in the specified directory.
    /// Searches for both .lrc and .lrcx files with matching filename.
    ///
    /// - Parameter directory: The directory to search in
    /// - Returns: URL of the found lyrics file, nil if not found
    private func locateTimedLyricsFile(in directory: URL) -> URL? {
        
        let possibleFiles = [
            directory.appendingPathComponent(defaultDisplayName + ".lrc"),
            directory.appendingPathComponent(defaultDisplayName + ".lrcx"),
        ]

        return possibleFiles.first { FileManager.default.fileExists(atPath: $0.path) }
    }

    /// Loads lyrics content from a file at the specified URL
    ///
    /// - Parameter url: The URL of the lyrics file
    /// - Returns: A Lyrics object if successfully loaded, nil otherwise
    private func loadTimedLyricsFromFile(at url: URL) -> TimedLyrics? {
        
        do {
            
            let lyricsText = try String(contentsOf: url, encoding: .utf8)
            return TimedLyrics(lyricsText)
            
        } catch {
            
            print("Failed to read lyrics file at \(url.path): \(error.localizedDescription)")
            return nil
        }
    }
}
