//
// LyricsFileDropView.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import AppKit

class LyricsFileDropView: NSView {

    override func awakeFromNib() {
        
        super.awakeFromNib()
        registerForDraggedTypes([.fileURL])
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        .generic
    }

    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        
        guard let urls = sender.urls, urls.count == 1, let url = urls.first, url.isSupportedLyricsFile else {return .invalidDragOperation}
        return .generic
    }

    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {true}
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        
        guard let lyricsFile = sender.urls?.first else {return false}
        
        Messenger.publish(.Lyrics.loadFromFile, payload: lyricsFile)
        return true
    }
}
