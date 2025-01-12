//
//  LibCueCD.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

class LibCueCD {
    
    let file: URL
    
    let rems: [LibCueREMType: LibCueREM]
    
    lazy var date: String? = rems[.date]?.value
    
    lazy var replayGain_albumGain: Float? = {
        
        if let gainStr = self.rems[.replayGain_albumGain]?.value.lowerCasedAndTrimmed().removingOccurrences(of: "db") {
            return Float(gainStr)
        }
        
        return nil
    }()
    
    lazy var replayGain_albumPeak: Float? = {
        
        if let gainStr = self.rems[.replayGain_albumPeak]?.value.trim() {
            return Float(gainStr)
        }
        
        return nil
    }()
    
    let cdTexts: [LibCueCDText]
    lazy var title: String? = cdTexts.first(where: {$0.pti == .title})?.value
    lazy var performer: String? = cdTexts.first(where: {$0.pti == .performer})?.value
    lazy var genre: String? = cdTexts.first(where: {$0.pti == .genre})?.value
    lazy var songwriter: String? = cdTexts.first(where: {$0.pti == .songwriter})?.value

    let numberOfTracks: Int
    let tracks: [LibCueTrack]
    
    init(file: URL) throws {
        
        self.file = file
        
        let filePtr: UnsafeMutablePointer<FILE> = fopen(file.path, "r")
        
        guard let cdPtr = cue_parse_file(filePtr) else {
            throw LibCueFileParseError(file: file)
        }
        
        self.numberOfTracks = Int(cd_get_ntrack(cdPtr))
        
        guard numberOfTracks > 0 else {
            throw LibCueNoTracksInFileError(file: file)
        }
        
        self.tracks = (1...numberOfTracks).compactMap {trackNum in
            
            if let trackPtr = cd_get_track(cdPtr, Int32(trackNum)) {
                return LibCueTrack(pointer: trackPtr)
            }
            
            return nil
        }
        
        guard tracks.isNonEmpty else {
            throw LibCueNoTracksInFileError(file: file)
        }
        
        if let cdTextPtr = cd_get_cdtext(cdPtr) {
            
            self.cdTexts = LibCuePTI.allCases.compactMap {pti in
                LibCueCDText(pointer: cdTextPtr, pti: pti, isTrack: false)
            }
            
        } else {
            self.cdTexts = []
        }
        
        if let remPtr = cd_get_rem(cdPtr) {
            
            var map: [LibCueREMType: LibCueREM] = [:]
            
            LibCueREMType.allCases.forEach {remType in
                map[remType] = LibCueREM(type: remType, pointer: remPtr)
            }
            
            self.rems = map
            
        } else {
            self.rems = [:]
        }
    }
}
