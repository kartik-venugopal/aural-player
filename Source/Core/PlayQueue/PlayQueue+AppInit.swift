//
// PlayQueue+AppInit.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation
import OrderedCollections

extension PlayQueue: TrackInitComponent {
    
    var urlsForTrackInit: [URL] {
        
        // Check if any launch parameters were specified
        if appDelegate.filesToOpen.isNonEmpty && preferences.playQueuePreferences.openWithAddMode == .replace {
            return appDelegate.filesToOpen
        }

        let persistentState = appPersistentState.playQueue
        let playQueuePreferences = preferences.playQueuePreferences
        
        switch playQueuePreferences.playQueueOnStartup {
            
        case .empty:
            return appDelegate.filesToOpen
            
        case .rememberFromLastAppLaunch:
            
            if let urls = persistentState?.tracks {
                return urls + appDelegate.filesToOpen
            }
            
        case .loadPlaylistFile:
            
            if let playlistFile = playQueuePreferences.playlistFile {
                return [playlistFile] + appDelegate.filesToOpen
            }
            
        case .loadFolder:
            
            if let folder = playQueuePreferences.tracksFolder {
                return [folder] + appDelegate.filesToOpen
            }
        }
        
        return appDelegate.filesToOpen
    }
    
    func preInitialize() {
        
        defer {
            
            for observer in observers.values {
                observer.startedAddingTracks(params: self.params)
            }
        }
        
        let autoplayPreferences = preferences.playbackPreferences.autoplay
        
        if appDelegate.filesToOpen.isNonEmpty {
            
            self.params = .init(autoplayFirstAddedTrack: autoplayPreferences.autoplayAfterOpeningTracks, markLoadedItemsForHistory: true)
            return
        }
        
        let autoplayOnStartup: Bool = autoplayPreferences.autoplayOnStartup
        let autoplayOption: AutoplayPlaybackPreferences.AutoplayOnStartupOption = autoplayPreferences.autoplayOnStartupOption
        
        let pqParmsWithAutoplayAndNoHistory: PlayQueueTrackLoadParams =
        autoplayOption == .firstTrack ?
            .init(autoplayFirstAddedTrack: autoplayOnStartup, markLoadedItemsForHistory: false) :
            .init(autoplayResumeSequence: autoplayOnStartup, markLoadedItemsForHistory: false)
        
        self.params = pqParmsWithAutoplayAndNoHistory
    }
    
    func initialize(withTracks tracks: OrderedDictionary<URL, Track>) {
        
        addTracks(tracks.values)
        
        var persistentState = appPersistentState.playQueue
        
        // Cue Sheet metadata
        for (file, track) in tracks {
            
            if track.cueSheetMetadata == nil,
               let metadata = persistentState?.cueSheetMetadata(forFile: file) {
                
                track.metadata.cueSheetMetadata = metadata
            }
        }
    }
    
    func postInitialize() {
        
        // Only appDelegate.filesToOpen can be considered for history
        
        for observer in observers.values {
            observer.doneAddingTracks(urls: appDelegate.filesToOpen, params: self.params)
        }
    }
}
