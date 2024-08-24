//
//  AlbumReplayGain.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

struct AlbumReplayGain: Codable {
    
    let albumName: String
    let files: Set<URL>
    
    let loudness: Double
    let replayGain: Double
    let peak: Double
    
    init(albumName: String, files: [URL], loudness: Double, replayGain: Double, peak: Double) {
        
        self.albumName = albumName
        self.files = Set(files)
        
        self.loudness = loudness
        self.replayGain = replayGain
        self.peak = peak
    }
    
    func containsResultsForAllFiles(_ targetFiles: [URL]) -> Bool {
        self.files.isSuperset(of: targetFiles)
    }
}
