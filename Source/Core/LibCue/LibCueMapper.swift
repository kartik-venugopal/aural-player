//
//  LibCueMapper.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation
import OrderedCollections

class LibCueMapper {
    
    static func mapToTracks(cd: LibCueCD) -> [FileSystemPlaylistTrack] {
        
        let parentDir = cd.file.parentDir
        
        var tracks: [FileSystemPlaylistTrack] = []
        
        var filenameToTracksMap: OrderedDictionary<String, [LibCueTrack]> = OrderedDictionary()
        
        for cueTrack in cd.tracks {
            
            if filenameToTracksMap[cueTrack.fileName] == nil {
                filenameToTracksMap[cueTrack.fileName] = [cueTrack]
            } else {
                filenameToTracksMap[cueTrack.fileName]?.append(cueTrack)
            }
        }
        
        for (fileName, cueTracks) in filenameToTracksMap {
            
            let file = parentDir.appendingPathComponent(fileName)
            
            if file.exists {
                tracks.append(mapToTrack(cueTracks, forCD: cd, inFile: file))
                
            } else {
                
                let fileNameWithoutExtension = file.nameWithoutExtension
                
                // Search for a file with the same name, but different extension
                if let fileWithMatchingName = file.parentDir.findFileWithoutExtensionNamed(fileNameWithoutExtension) {
                    tracks.append(mapToTrack(cueTracks, forCD: cd, inFile: fileWithMatchingName))
                }
            }
        }
        
        return tracks
    }
    
    private static func mapToTrack(_ cueTracks: [LibCueTrack], forCD cd: LibCueCD, inFile file: URL) -> FileSystemPlaylistTrack {
        
        if cueTracks.count == 1 {
            
            let metadata = getMetadataFromCDAndTrack(cd, forTrack: cueTracks[0])
            return FileSystemPlaylistTrack(file: file, cueSheetMetadata: metadata)
        }
        
        let metadata = getMetadataFromCD(cd)
        
        metadata.chapters = cueTracks.enumerated().map {index, cueTrack in
            Chapter(cueTrack: cueTrack, cueCD: cd, index: index)
        }
        
        return FileSystemPlaylistTrack(file: file, cueSheetMetadata: metadata)
    }
    
    private static func getMetadataFromCD(_ cd: LibCueCD) -> CueSheetMetadata {
        
        let metadata: CueSheetMetadata = .init()
        
        metadata.album = cd.title
        metadata.albumArtist = cd.performer
        metadata.genre = cd.genre
        metadata.date = cd.date
        
        metadata.replayGain = .init(trackGain: cd.replayGain_albumGain,
                                    trackPeak: cd.replayGain_albumPeak)
        
        return metadata
    }
    
    private static func getMetadataFromCDAndTrack(_ cd: LibCueCD, forTrack track: LibCueTrack) -> CueSheetMetadata {
        
        let metadata: CueSheetMetadata = .init()
        
        metadata.album = cd.title
        metadata.albumArtist = cd.performer
        metadata.genre = cd.genre
        metadata.date = cd.date
        
        metadata.replayGain = .init(trackGain: track.replayGain_trackGain,
                                    trackPeak: track.replayGain_trackPeak,
                                    albumGain: cd.replayGain_albumGain,
                                    albumPeak: cd.replayGain_albumPeak)
        
        metadata.artist = track.performer
        metadata.title = track.title
        metadata.composer = track.composer
        
        metadata.arranger = track.arranger
        metadata.songwriter = track.songwriter
        metadata.message = track.message
        
        return metadata
    }
}

extension Chapter {
    
    convenience init(cueTrack: LibCueTrack, cueCD: LibCueCD, index: Int) {
        
        let theTitle: String
        
        if let title = cueTrack.title {
            
            if let performer = cueTrack.performer {
                theTitle = "\(performer) - \(title)"
            } else {
                theTitle = title
            }
            
        } else {
            theTitle = "Chapter \(index + 1)"
        }
        
        self.init(title: theTitle, startTime: cueTrack.start ?? 0, duration: cueTrack.length)
    }
}
