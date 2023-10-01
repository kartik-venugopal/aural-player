//
//  CoverArtReader.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A functional contract for a service that reads cover art for a track.
///
protocol CoverArtReaderProtocol {
    
    func getCoverArt(forTrack track: Track) -> CoverArt?
}

///
/// A service that reads cover art for a track.
///
class CoverArtReader: CoverArtReaderProtocol {
    
    private let readers: [CoverArtReaderProtocol]
    
    init(_ fileCoverArtReader: FileCoverArtReader, _ musicBrainzCoverArtReader: MusicBrainzCoverArtReader) {
        self.readers = [fileCoverArtReader, musicBrainzCoverArtReader]
    }
    
    func getCoverArt(forTrack track: Track) -> CoverArt? {
        
        CoverArtCache.forFile(track.file)?.art ??
        readers.firstNonNilMappedValue {$0.getCoverArt(forTrack: track)}
    }
}
