//
//  Library.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

class Library {
    
    private(set) var tracks: [Track] = []
    
    var size: Int {tracks.count}
    
    init() {
        
        let bundle = Bundle.init(for: PlaylistTestCase.self)
        guard let path = bundle.path(forResource: "library", ofType: "txt") else {
            
            print("Unable to obtain library file from bundle.")
            return
        }
        
        let libraryFile = URL(fileURLWithPath: path)
        var fileContents: String!
        
        do {
            fileContents = try String(contentsOf: libraryFile, encoding: .utf8)
            
        } catch {
            print("Unable to read library file.")
        }
        
        guard fileContents != nil else {
            
            print("Unable to read library file.")
            return
        }
        
        let lines = fileContents.components(separatedBy: .newlines).filter({!$0.isEmptyAfterTrimming})
        
        for line in lines {
            
            let fields = line.components(separatedBy: ",")
            guard fields.count == 7 else {continue}
            
            let file = URL(fileURLWithPath: fields[0])
            let track = MockTrack(file)
            
            let title = fields[2].isEmptyAfterTrimming ? nil : fields[2]
            let artist = fields[3].isEmptyAfterTrimming ? nil : fields[3]
            let album = fields[4].isEmptyAfterTrimming ? nil : fields[4]
            let genre = fields[5].isEmptyAfterTrimming ? nil : fields[5]
            
            let durationStr = fields[6]
            let duration = Double(durationStr) ?? Double.random(in: 60...600)
            
            let metadata = fileMetadata(title, artist, album, genre, duration)
            track.setPlaylistMetadata(from: metadata)
            
            tracks.append(track)
        }
    }
    
    func tracksWithNameContaining(_ text: String, caseSensitive: Bool) -> [Track] {
        
        let comparisonText = caseSensitive ? text : text.lowercased()
        
        return tracks.filter {
            
            let fileName = caseSensitive ? $0.fileSystemInfo.fileName : $0.fileSystemInfo.fileName.lowercased()
            let displayName = caseSensitive ? $0.displayName : $0.displayName.lowercased()
            
            return fileName.contains(comparisonText) || displayName.contains(comparisonText)
        }
    }
    
    func tracksWithNameEqualing(_ text: String, caseSensitive: Bool) -> [Track] {
        
        let comparisonText = caseSensitive ? text : text.lowercased()
        
        return tracks.filter {
            
            let fileName = caseSensitive ? $0.fileSystemInfo.fileName : $0.fileSystemInfo.fileName.lowercased()
            let displayName = caseSensitive ? $0.displayName : $0.displayName.lowercased()
            
            return fileName == comparisonText || displayName == comparisonText
        }
    }
    
    func tracksWithNameStartingWith(_ text: String, caseSensitive: Bool) -> [Track] {
        
        let comparisonText = caseSensitive ? text : text.lowercased()
        
        return tracks.filter {
            
            let fileName = caseSensitive ? $0.fileSystemInfo.fileName : $0.fileSystemInfo.fileName.lowercased()
            let displayName = caseSensitive ? $0.displayName : $0.displayName.lowercased()
            
            return fileName.hasPrefix(comparisonText) || displayName.hasPrefix(comparisonText)
        }
    }
    
    func tracksWithNameEndingWith(_ text: String, caseSensitive: Bool) -> [Track] {
        
        let comparisonText = caseSensitive ? text : text.lowercased()
        
        return tracks.filter {
            
            let fileName = caseSensitive ? $0.fileSystemInfo.fileName : $0.fileSystemInfo.fileName.lowercased()
            let displayName = caseSensitive ? $0.displayName : $0.displayName.lowercased()
            
            return fileName.hasSuffix(comparisonText) || displayName.hasSuffix(comparisonText)
        }
    }
    
    func uniqueArtists() -> Set<String> {
        Set(tracks.compactMap {$0.artist})
    }
    
    func randomTrackNames(count: Int) -> Set<String> {
        
        var names: Set<String> = Set()
        
        while names.count < count {
            
            let index = Int.random(in: tracks.indices)
            let track = tracks[index]
            names.insert(track.displayName)
        }
        
        return names
    }
}
