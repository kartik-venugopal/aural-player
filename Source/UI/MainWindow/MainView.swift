//
//  MainView.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa
import AppKit

class MainView: NSView {
    
    private lazy var playlistPreferences: PlaylistPreferences = objectGraph.preferences.playlistPreferences
    
    private lazy var playlist: PlaylistDelegateProtocol = objectGraph.playlistDelegate
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        registerForDraggedTypes([.file_URL])
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return NSDragOperation.generic
    }

    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        
        guard let urls = sender.urls, atLeastOneSupportedURL(urls) else {return []}
        return NSDragOperation.generic
    }

    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        return true
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        
        guard let urls = sender.urls else {return false}
        
        if playlistPreferences.dragDropAddMode == .replace || (playlistPreferences.dragDropAddMode == .hybrid && NSEvent.optionFlagSet) {
            playlist.clear()
        }
        
        playlist.addFiles(urls)
        
        return true
    }
    
    private func atLeastOneSupportedURL(_ urls: [URL]) -> Bool {
        
        for url in urls {
            
            if url.isAliasOrSymLink {
                print("\(url.lastPathComponent) is a symLink !")
            }
            
            if url.isDirectory || url.isAliasOrSymLink || url.isSupported {
                return true
            }
        }
        
        return false
    }
}
