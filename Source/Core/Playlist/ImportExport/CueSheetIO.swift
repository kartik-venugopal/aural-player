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
        
        do {
            
            let cueCD = try LibCueCD(file: playlistFile)
            let tracks = LibCueMapper.mapToTracks(cd: cueCD)
            
            return FileSystemPlaylist(file: playlistFile, tracks: tracks)
            
        } catch let error as LibCueError {
            NSLog("Failed to parse Cue sheet '\(playlistFile.path)'. Error: \(error.message)")
            
        } catch {
            NSLog("Failed to parse Cue sheet '\(playlistFile.path)'. Error: \(error.localizedDescription)")
        }

        return nil
    }
    
//    private static func mapCueSheetFile
//    ToPlaylistTrack(_ cueSheetFile: CueSheetFile, inPlaylistFile playlistFile: URL, forCueSheet cueSheet: CueSheet) -> FileSystemPlaylistTrack? {
//
//        let parentDir = playlistFile.parentDir
//        let file = parentDir.appendingPathComponent(cueSheetFile.filename, isDirectory: false).resolvedURL
//        
//        guard file.exists else {
//            
//            NSLog("Error while parsing Cue Sheet '\(playlistFile.lastPathComponent)': File not found - '\(file.path)'")
//            return nil
//        }
//        
//        guard file.isSupportedAudioFile else {
//            
//            NSLog("Error while parsing Cue Sheet '\(playlistFile.lastPathComponent)': File not supported - '\(file.path)'")
//            return nil
//        }
//        
//        let cueSheetTracks = cueSheetFile.tracks
//        
//        // No tracks, just filename
//        guard cueSheetTracks.isNonEmpty else {
//            return .init(file: file, cueSheetMetadata: nil)
//        }
//        
//        let metadata: CueSheetMetadata = getMetadataFromCueSheet(cueSheet)
//        
//        if cueSheetTracks.count == 1 {
//            
//            if let cueSheetTrack = cueSheetTracks.first {
//            
//                metadata.performer = cueSheetTrack.performer
//                metadata.title = cueSheetTrack.title
//            }
//            
//        } else {
//            
//            func correctNumber(_ number: Double) -> Double {
//                (number.isNaN || number < 0) ? 0 : number
//            }
//            
//            // Multiple tracks for file, map to chapters
//            
//            let sortedTracks = cueSheetTracks.sorted(by: {($0.startTime ?? 0) < ($1.startTime ?? 0)})
//            metadata.chapters = []
//            
//            for (index, track) in sortedTracks.enumerated() {
//
//                guard let start = track.startTime else {continue}
//                
//                let title = Self.chapterTitleForCueSheetTrack(track) ?? "Chapter \(index + 1)"
//                
//                // Use start times to compute end times and durations
//                let end = index == sortedTracks.lastIndex ? 0 : (sortedTracks[index + 1].startTime ?? 0)
//                
//                // Validate the time fields for NaN and negative values
//                let correctedStart = correctNumber(start)
//                let correctedEnd = correctNumber(end)
//                
//                metadata.chapters?.append(Chapter(title: title,
//                                                  startTime: correctedStart,
//                                                  endTime: correctedEnd))
//            }
//            
//            if let chapters = metadata.chapters, chapters.count == 1 {
//                
//                metadata.chapters = nil
//                
//                if let track = sortedTracks.first(where: {$0.startTime == chapters[0].startTime}) {
//                    
//                    metadata.performer = track.performer
//                    metadata.title = track.title
//                }
//            }
//        }
//        
//        return FileSystemPlaylistTrack(file: file, cueSheetMetadata: metadata)
//    }
//    
//    private static func chapterTitleForCueSheetTrack(_ track: CueSheetTrack) -> String? {
//        
//        guard let theTitle = track.title else {return nil}
//            
//        if let performer = track.performer {
//            return "\(performer) - \(theTitle)"
//        } else {
//            return theTitle
//        }
//    }
//    
//    private static func getMetadataFromCueSheet(_ cueSheet: CueSheet) -> CueSheetMetadata {
//        
//        let metadata: CueSheetMetadata = .init()
//        
//        metadata.album = cueSheet.album
//        metadata.albumPerformer = cueSheet.albumPerformer
//        metadata.comment = cueSheet.comment
//        metadata.date = cueSheet.date
//        metadata.discID = cueSheet.discID
//        metadata.genre = cueSheet.genre
//        
//        return metadata
//    }
}
