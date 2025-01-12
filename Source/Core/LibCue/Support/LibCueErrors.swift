//
//  LibCueErrors.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class LibCueError: DisplayableError {}

class LibCueFileParseError: LibCueError {
    
    let file: URL
    
    init(file: URL) {
        
        self.file = file
        super.init("LibCue was unable to parse the file: '\(file.path). Is it a valid Cue sheet ?'")
    }
}

class LibCueNoTracksInFileError: LibCueError {
    
    let file: URL
    
    init(file: URL) {
        
        self.file = file
        super.init("LibCue was unable to find any tracks in the file: '\(file.path). Is it a valid Cue sheet ?'")
    }
}

//class LibCueTrackRetrievalError: LibCueError {
//    
//    let file: URL
//    let trackNum: Int
//    
//    init(file: URL, trackNum: Int) {
//        
//        self.file = file
//        self.trackNum = trackNum
//        
//        super.init("LibCue was unable to retrieve track number \(trackNum) in the file: '\(file.path). Is it a valid Cue sheet ?'")
//    }
//}
//
//class LibCueNoFilenameInTrackError: LibCueError {
//    
//    let file: URL
//    let trackNum: Int
//    
//    init(file: URL, trackNum: Int) {
//        
//        self.file = file
//        self.trackNum = trackNum
//        
//        super.init("LibCue was unable to find a filename for track number \(trackNum) in the file: '\(file.path). Is it a valid Cue sheet ?'")
//    }
//}
