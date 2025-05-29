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
        if appDelegate.filesToOpen.isNonEmpty {
            return appDelegate.filesToOpen
        }

        let persistentState = appPersistentState.playQueue
        let playQueuePreferences = preferences.playQueuePreferences
        
        switch playQueuePreferences.playQueueOnStartup {
            
        case .empty:
            return []
            
        case .rememberFromLastAppLaunch:
            
            if let urls = persistentState?.tracks {
                return urls
            }
            
        case .loadPlaylistFile:
            
            if let playlistFile = playQueuePreferences.playlistFile {
                return [playlistFile]
            }
            
        case .loadFolder:
            
            if let folder = playQueuePreferences.tracksFolder {
                return [folder]
            }
        }
        
        return []
    }
    
    func preInitialize() {
        
        let autoplayPreferences = preferences.playbackPreferences.autoplay
        
        if appDelegate.filesToOpen.isNonEmpty {
            
            self.params = .init(autoplayFirstAddedTrack: autoplayPreferences.autoplayAfterOpeningTracks)
            return
        }
        
        let autoplayOnStartup: Bool = autoplayPreferences.autoplayOnStartup
        let autoplayOption: AutoplayPlaybackPreferences.AutoplayOnStartupOption = autoplayPreferences.autoplayOnStartupOption
        
        let pqParmsWithAutoplayAndNoHistory: PlayQueueTrackLoadParams =
        autoplayOption == .firstTrack ?
            .init(autoplayFirstAddedTrack: autoplayOnStartup, markLoadedItemsForHistory: false) :
            .init(autoplayResumeSequence: autoplayOnStartup, markLoadedItemsForHistory: false)
        
        self.params = pqParmsWithAutoplayAndNoHistory
        
        for observer in observers.values {
            observer.startedAddingTracks(params: self.params)
        }
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
        
        for observer in observers.values {
            observer.doneAddingTracks(urls: tracks.map {$0.file})
        }
    }
}
