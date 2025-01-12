//
//  CompactPlayerArtView.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class CompactPlayerArtView: RoundedImageView {

    override func awakeFromNib() {
        
        super.awakeFromNib()
        registerForDraggedTypes([.fileURL])
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        .generic
    }

    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        
        guard let urls = sender.urls, URL.atLeastOneSupportedURL(in: urls) else {return .invalidDragOperation}
        return .generic
    }

    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {true}

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        
        guard let urls = sender.urls else {return false}
        
        playQueueDelegate.loadTracks(from: urls, params: .init(autoplayFirstAddedTrack: true))
        return true
    }
}
