//
//  FileCoverArtReader.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

class FileCoverArtReader: CoverArtReaderProtocol {
    
    private var fileReader: FileReaderProtocol
    
    private var searchedTracks: ConcurrentSet<Track> = ConcurrentSet()
    
    init(_ fileReader: FileReaderProtocol) {
        self.fileReader = fileReader
    }
 
    func getCoverArt(forTrack track: Track) -> CoverArt? {
        
        if searchedTracks.contains(track) {return nil}
        
        searchedTracks.insert(track)
        return fileReader.getArt(for: track.file)
    }
}
