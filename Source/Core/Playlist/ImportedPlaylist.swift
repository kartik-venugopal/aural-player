//
//  ImportedPlaylist.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class ImportedPlaylist: TrackList, PlaylistProtocol, UserManagedObject {
    
    var file: URL
    var name: String
    
    override var displayName: String {
        name
    }
    
    var key: String {

        get {name}
        set {name = newValue}
    }

    let userDefined: Bool = true
    
    init(file: URL, tracks: [Track]) {
        
        self.file = file
        self.name = file.nameWithoutExtension
        
        super.init()
        addTracks(tracks)
    }
    
    override func loadTracks(from urls: [URL], atPosition position: Int?) {}
}
