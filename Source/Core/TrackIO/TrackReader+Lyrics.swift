//
// TrackReader+Lyrics.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation
import LyricsCore
import LyricsService
import MusicPlayer
import LyricsXCore
import LyricsUI

extension TrackReader {
    
    func loadExternalLyrics(for track: Track, immediate: Bool) {
        
        guard track.externalOrEmbeddedTimedLyrics == nil else {return}
        
        // Load lyrics from previously assigned external file
        if let externalLyricsFile = track.metadata.externalLyricsFile, externalLyricsFile.exists,
           let lyrics = loadLyricsFromFile(at: externalLyricsFile) {
            
            track.metadata.externalTimedLyrics = TimedLyrics(from: lyrics, trackDuration: track.duration)
            Messenger.publish(TrackInfoUpdatedNotification(updatedTrack: track, updatedFields: .lyrics))
            return
        }
        
        // Look for lyrics in candidate directories
        let lyricsFolder = preferences.metadataPreferences.lyrics.lyricsFilesDirectory.value
        
        for dir in [lyricsFolder, track.file.parentDir, FilesAndPaths.lyricsDir].compactMap({$0}) {
            
            if loadLyricsFromDirectory(dir, for: track) {
                
                Messenger.publish(TrackInfoUpdatedNotification(updatedTrack: track, updatedFields: .lyrics))
                return
            }
        }
        
        // Online search
        guard onlineSearchEnabled, track.title != nil && track.artist != nil else {return}
        
        Task.detached(priority: immediate ? .userInitiated : .utility) {
            
            guard let bestLyrics = await LyricsSearchService().searchLyrics(for: track) else {return}
            
            let timedLyrics = TimedLyrics(from: bestLyrics, trackDuration: track.duration)
            track.metadata.externalTimedLyrics = timedLyrics
            
            Messenger.publish(TrackInfoUpdatedNotification(updatedTrack: track, updatedFields: .lyrics))
            
            if let cachedLyricsFile = bestLyrics.persistToFile(track.defaultDisplayName) {
                track.metadata.externalLyricsFile = cachedLyricsFile
            }
        }
    }
    
    /// Loads lyrics from a specified directory by searching for .lrc or .lrcx files
    ///
    /// - Parameter directory: The directory to search for lyrics files
    /// - Returns: A Lyrics object if found and successfully loaded, nil otherwise
    ///
    private func loadLyricsFromDirectory(_ directory: URL, for track: Track) -> Bool {
        
        let possibleFiles = SupportedTypes.lyricsFileExtensions.map {
            directory.appendingPathComponent(track.defaultDisplayName).appendingPathExtension($0)
        }
        
        if let lyricsFile = possibleFiles.first(where: {$0.exists}) {
            return loadTimedLyricsFromFile(at: lyricsFile, for: track)
        }
        
        return false
    }
    
    func loadTimedLyricsFromFile(at url: URL, for track: Track) -> Bool {
        
        guard let lyrics = loadLyricsFromFile(at: url) else {return false}
        
        track.metadata.externalTimedLyrics = TimedLyrics(from: lyrics, trackDuration: track.duration)
        track.metadata.externalLyricsFile = url
        return true
    }

    /// Loads lyrics content from a file at the specified URL
    ///
    /// - Parameter url: The URL of the lyrics file
    /// - Returns: A Lyrics object if successfully loaded, nil otherwise
    ///
    private func loadLyricsFromFile(at url: URL) -> LyricsCore.Lyrics? {
        
        do {
            
            let lyricsText = try String(contentsOf: url, encoding: .utf8)
            return LyricsCore.Lyrics(lyricsText)
            
        } catch {
            
            print("Failed to read lyrics file at \(url.path): \(error.localizedDescription)")
            return nil
        }
    }
    
    private var onlineSearchEnabled: Bool {
        preferences.metadataPreferences.lyrics.enableOnlineSearch.value
    }
    
    func searchForLyricsOnline(for track: Track, uiUpdateBlock: @escaping (TimedLyrics?) -> Void) async {
        
        Task.detached(priority: .userInitiated) {
            
            guard let bestLyrics = await LyricsSearchService().searchLyrics(for: track) else {
                
                await MainActor.run {
                    uiUpdateBlock(nil)
                }
                
                return
            }
            
            let timedLyrics = TimedLyrics(from: bestLyrics, trackDuration: track.duration)
            track.metadata.externalTimedLyrics = timedLyrics
            
            // Update the UI
            await MainActor.run {
                uiUpdateBlock(timedLyrics)
            }
            
            if let cachedLyricsFile = bestLyrics.persistToFile(track.defaultDisplayName) {
                track.metadata.externalLyricsFile = cachedLyricsFile
            }
        }
    }
}

extension LyricsSearchService {
    
    func searchLyrics(for track: Track) async -> Lyrics? {
        
        let musicTrack = MusicTrack(
            id: track.defaultDisplayName,
            title: track.title,
            album: track.album,
            artist: track.artist,
            duration: track.duration,
            fileURL: track.file,
            artwork: track.art?.originalImage?.image,
            originalTrack: track
        )
        
        let allLyrics = await searchLyrics(with: musicTrack.searchQuery)
        return allLyrics.bestMatch(for: musicTrack)
    }
}
