//
//  PlayQueueDelegate+Init.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

extension PlayQueueDelegate {
    
    func initialize(fromPersistentState persistentState: PlayQueuePersistentState?, appLaunchFiles: [URL]) {
        
        lazy var playQueuePreferences = preferences.playQueuePreferences
        lazy var playbackPreferences = preferences.playbackPreferences
        
        // Check if any launch parameters were specified
        if appLaunchFiles.isNonEmpty {
            
            // Launch parameters  specified, override playlist saved state and add file paths in params to playlist
            loadTracks(from: appLaunchFiles, params: .init(autoplay: playbackPreferences.autoplayAfterOpeningTracks.value, markLoadedItemsForHistory: false))
            
        } else {
            
            guard let state = persistentState else {return}
            
            if playQueuePreferences.playQueueOnStartup.value == .rememberFromLastAppLaunch, let files = state.tracks, files.isNonEmpty {
                
                // No launch parameters specified, load playlist saved state if "Remember state from last launch" preference is selected
                loadTracks(from: files, params: .init(autoplay: playbackPreferences.autoplayOnStartup.value, markLoadedItemsForHistory: false))
            }
        }
        
        initializeHistory(fromPersistentState: persistentState?.history)
        
        // TODO: Load from playlist / playlist file / folder / group
        
        //        } else if playlistPreferences.playlistOnStartup == .loadFile,
        //                  let playlistFile: URL = playlistPreferences.playlistFile {
        //
        //            addFiles_async([playlistFile], AutoplayOptions(playbackPreferences.autoplayOnStartup), userAction: false)
        //
        //        } else if playlistPreferences.playlistOnStartup == .loadFolder,
        //                  let folder: URL = playlistPreferences.tracksFolder {
        //
        //            addFiles_async([folder], AutoplayOptions(playbackPreferences.autoplayOnStartup), userAction: false)
        //        }
    }
    
    private func initializeHistory(fromPersistentState persistentState: HistoryPersistentState?) {
        
        if let lastPlaybackPosition = persistentState?.lastPlaybackPosition {
            self.markLastPlaybackPosition(lastPlaybackPosition)
        }
        
        // Restore the history model object from persistent state.
        guard let recentItemsState = persistentState?.recentItems else {return}
        
        // Move to a background thread to unblock the main thread.
        DispatchQueue.global(qos: .utility).async {
            
            for item in recentItemsState.compactMap(self.historyItemForState) {
                self.recentItems[item.key] = item
            }
        }
    }
    
    private func historyItemForState(_ state: HistoryItemPersistentState) -> HistoryItem? {
        
        guard let itemType = state.itemType, let lastEventTime = state.lastEventTime, let eventCount = state.eventCount else {return nil}
        
        var item: HistoryItem? = nil
        
        switch itemType {
            
        case .track:
            
            guard let trackFile = state.trackFile else {return nil}
            
            let track = Track(trackFile)
            item = TrackHistoryItem(track: track, lastEventTime: lastEventTime, eventCount: eventCount)
            
            TrackReader.mediumPriorityQueue.addOperation {
                trackReader.loadPrimaryMetadata(for: track)
            }
            
        case .playlistFile:
            
            if let playlistFile = state.playlistFile {
                item = PlaylistFileHistoryItem(playlistFile: playlistFile, lastEventTime: lastEventTime, eventCount: eventCount)
            }
            
        case .folder:
            
            if let folder = state.folder {
                item = FolderHistoryItem(folder: folder, lastEventTime: lastEventTime, eventCount: eventCount)
            }
            
        case .group:
            
            if let groupName = state.groupName, let groupType = state.groupType {
                item = GroupHistoryItem(groupName: groupName, groupType: groupType, lastEventTime: lastEventTime, eventCount: eventCount)
            }
        }
        
        return item
    }
}
