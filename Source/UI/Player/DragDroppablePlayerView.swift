//
//  DragDroppablePlayerView.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class DragDroppablePlayerView: NSView {

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
    
    var shouldAutoplayAfterAdding: Bool {
        
        let autoplayAfterAdding: Bool = preferences.playbackPreferences.autoplayAfterAddingTracks.value
        lazy var option: PlaybackPreferences.AutoplayAfterAddingOption = preferences.playbackPreferences.autoplayAfterAddingOption.value
        lazy var playerIsStopped: Bool = playbackInfoDelegate.state.isStopped
        
        return autoplayAfterAdding && (option == .always || playerIsStopped)
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        
        guard let files = sender.urls else {return false}
        
        let addMode = preferences.playQueuePreferences.dragDropAddMode.value
        let clearQueue: Bool = addMode == .replace || (addMode == .hybrid && NSEvent.optionFlagSet)
        
        playQueueDelegate.loadTracks(from: files, params: .init(clearQueue: clearQueue, autoplayFirstAddedTrack: shouldAutoplayAfterAdding))
        
        return true
    }
}
