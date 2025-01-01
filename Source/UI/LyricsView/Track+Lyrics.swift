//
//  Track+Lyrics.swift
//  Aural
//
//  Created by tisfeng on 2024/12/17.
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//

import Foundation
import LyricsCore
import MusicPlayer

extension Lyrics {
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
    private func persistLyrics(_ lyrics: Lyrics, to url: URL) {
        url.parentDir.createDirectory()

        do {
            try lyrics.description.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            print("Failed to write lyrics to \(url.path): \(error.localizedDescription)")
        }
    }
}

extension Track {

    /// Fetches local lyrics for this track from multiple sources in the following order:
    /// 1. Lyrics directory
    /// 2. Audio file directory
    /// 3. Embedded lyrics in the audio file
    ///
    /// - Returns: A Lyrics object if found, nil otherwise
    func fetchLocalLyrics() -> Lyrics? {

        // 1. First try to find lyrics from Aural lyrics directory
        if let lyrics = loadLyricsFromDirectory(FilesAndPaths.lyricsDir) {
            return lyrics
        }

        // 2. Then try to find lyrics from audio file directory
        if let lyrics = loadLyricsFromDirectory(file.deletingLastPathComponent()) {
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
    private func locateLyricsFile(in directory: URL) -> URL? {
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

extension Track {
    var musicTrack: MusicTrack {
        return MusicTrack(
            id: defaultDisplayName,
            title: title,
            album: album,
            artist: artist,
            duration: duration,
            fileURL: file,
            artwork: art?.originalImage?.image,
            originalTrack: self
        )
    }
}
