//
//  CueSheetIO.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation


// *** Code in early stages of development. Not production-ready.

class CueSheetIO: PlaylistIOProtocol {
    
    static func savePlaylist(tracks: [Track], toFile file: URL) {
        
    }
    
    static func loadPlaylist(fromFile playlistFile: URL) -> FileSystemPlaylist? {

        guard let cueSheet = parseCueSheet(fromFile: playlistFile) else {return nil}

        let parentDir = playlistFile.parentDir
        
        let tracks: [FileSystemPlaylistTrack] = cueSheet.files.compactMap {
            Self.mapCueSheetFileToPlaylistTrack($0, inParentDir: parentDir, forCueSheet: cueSheet)
        }
        
        return FileSystemPlaylist(file: playlistFile, tracks: tracks)
    }
    
    private static func mapCueSheetFileToPlaylistTrack(_ cueSheetFile: CueSheetFile, inParentDir parentDir: URL, forCueSheet cueSheet: CueSheet) -> FileSystemPlaylistTrack? {
        
        let file = parentDir.appendingPathComponent(cueSheetFile.filename, isDirectory: false)
        
        let cueSheetTracks = cueSheetFile.tracks
        guard cueSheetTracks.isNonEmpty else {return nil}
        
        let metadata: CueSheetMetadata = getMetadataFromCueSheet(cueSheet)
        
        if cueSheetTracks.count == 1 {
            
            if let cueSheetTrack = cueSheetTracks.first {
            
                metadata.performer = cueSheetTrack.performer
                metadata.title = cueSheetTrack.title
            }
            
        } else {
            
            func correctNumber(_ number: Double) -> Double {
                (number.isNaN || number < 0) ? 0 : number
            }
            
            // Multiple tracks for file, map to chapters
            
            let sortedTracks = cueSheetTracks.sorted(by: {($0.startTime ?? 0) < ($1.startTime ?? 0)})
            metadata.chapters = []
            
            for (index, track) in sortedTracks.enumerated() {
                
                let title = Self.chapterTitleForCueSheetTrack(track) ?? "Chapter \(index + 1)"
                let start = track.startTime ?? 0
                
                // Use start times to compute end times and durations
                let end = index == sortedTracks.lastIndex ? 0 : (sortedTracks[index + 1].startTime ?? 0)
                
                // Validate the time fields for NaN and negative values
                let correctedStart = correctNumber(start)
                let correctedEnd = correctNumber(end)
                
                metadata.chapters?.append(Chapter(title: title,
                                                  startTime: correctedStart,
                                                  endTime: correctedEnd))
            }
        }
        
        return FileSystemPlaylistTrack(file: file, cueSheetMetadata: metadata)
    }
    
    private static func chapterTitleForCueSheetTrack(_ track: CueSheetTrack) -> String? {
        
        guard let theTitle = track.title else {return nil}
            
        if let performer = track.performer {
            return "\(performer) - \(theTitle)"
        } else {
            return theTitle
        }
    }
    
    private static func getMetadataFromCueSheet(_ cueSheet: CueSheet) -> CueSheetMetadata {
        
        let metadata: CueSheetMetadata = .init()
        
        metadata.album = cueSheet.album
        metadata.albumPerformer = cueSheet.albumPerformer
        metadata.comment = cueSheet.comment
        metadata.date = cueSheet.date
        metadata.discID = cueSheet.discID
        metadata.genre = cueSheet.genre
        
        return metadata
    }
}
