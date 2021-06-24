//
//  CoverArtReader.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

protocol CoverArtReaderProtocol {
    
    func getCoverArt(forTrack track: Track) -> CoverArt?
}

class CoverArtReader: CoverArtReaderProtocol {
    
    private let readers: [CoverArtReaderProtocol]
    
    init(_ fileCoverArtReader: FileCoverArtReader, _ musicBrainzCoverArtReader: MusicBrainzCoverArtReader) {
        self.readers = [fileCoverArtReader, musicBrainzCoverArtReader]
    }
    
    func getCoverArt(forTrack track: Track) -> CoverArt? {
        readers.firstNonNilMappedValue {$0.getCoverArt(forTrack: track)}
    }
}
