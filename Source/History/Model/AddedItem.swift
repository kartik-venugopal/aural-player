//
//  AddedItem.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// Represents an item that was added to the playlist in the past, i.e. either a folder, audio file, or playlist file.
///
class AddedItem: HistoryItem {
    
    // Folder or playlist added for the first time
    init(_ file: URL, _ time: Date) {
        
        super.init(file, file.lastPathComponent, time)
        loadDisplayInfoFromFile(true)
    }
    
    override init(_ file: URL, _ displayName: String, _ time: Date) {
        super.init(file, displayName, time)
    }
    
    init(_ track: Track, _ time: Date) {
        
        super.init(track.file, track.displayName, time)
        self.track = track
    }
    
    func loadDisplayInfoFromFile(_ setDisplayName: Bool) {
        
        // Resolve sym links and aliases
        self.file = file.resolvedURL
        
        if file.isDirectory {
            
            // Display name is last path component
            // Art is folder icon
            
            if setDisplayName {
                self.displayName = file.lastPathComponents(count: 4)
            }
            
        } else {
            
            // Single file - playlist or track
            let fileExtension = file.lowerCasedExtension
            
            if SupportedTypes.playlistExtensions.contains(fileExtension) {
                
                // Playlist
                // Display name is last path component
                // Art is playlist icon
                if setDisplayName {
                    self.displayName = file.lastPathComponents(count: 4)
                }
            }
        }
    }
}
