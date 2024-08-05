//
//  CueSheetIO+Model.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class CueSheet {
    
    var files: [CueSheetFile] = []
    
    var album: String?
    var albumPerformer: String?
    var genre: String?
    var date: String?
    var discID: String?
    var comment: String?
}

class CueSheetFile {
    
    let filename: String
    var tracks: [CueSheetTrack] = []
    
    init(filename: String) {
        self.filename = filename
    }
}

struct CueSheetTrack {
    
    let title: String?
    let performer: String?
    let startTime: Double?
}
