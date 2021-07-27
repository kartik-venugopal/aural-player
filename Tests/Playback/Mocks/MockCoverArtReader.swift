//
//  MockCoverArtReader.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class MockCoverArtReader: CoverArtReaderProtocol {
    
    func getCoverArt(forTrack track: Track) -> CoverArt? {nil}
}
