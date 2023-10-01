//
//  MainView.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa
import AppKit

/*
    Custom view for the main window's content view. To receive drag/drop events
    (i.e. files/folders) from Finder.
 */
class MainView: NSView {

    private lazy var playlist: PlaylistDelegateProtocol = objectGraph.playlistDelegate
    private lazy var playlistPreferences: PlaylistPreferences = objectGraph.preferences.playlistPreferences
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        registerForDraggedTypes([.file_URL])
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return NSDragOperation.generic
    }

    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        
        guard let urls = sender.urls, URL.atLeastOneSupportedURL(in: urls) else {return []}
        return NSDragOperation.generic
    }

    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        return true
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        
        guard let urls = sender.urls else {return false}
        
        let addMode = playlistPreferences.dragDropAddMode
        playlist.addFiles(urls, clearBeforeAdding: addMode == .replace || (addMode == .hybrid && NSEvent.optionFlagSet))
        
        return true
    }
}
