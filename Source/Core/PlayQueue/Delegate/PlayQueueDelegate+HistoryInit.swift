//
// PlayQueueDelegate+HistoryInit.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation
import OrderedCollections

extension PlayQueueDelegate: TrackInitComponent {
    
    var urlsForTrackInit: [URL] {
        appPersistentState.playQueue?.history?.recentItems?.filter {$0.itemType == .track}.compactMap {$0.trackFile} ?? []
    }
    
    func preInitialize() {}
    
    func initialize(withTracks tracks: OrderedDictionary<URL, Track>) {
        
        guard let recentItemsState = appPersistentState.playQueue?.history?.recentItems else {return}
        
        for state in recentItemsState {
            
            guard let itemType = state.itemType, state.addCount != nil || state.playCount != nil else {continue}
            
            var item: HistoryItem? = nil
            
            switch itemType {
                
            case .track:
                
                guard let trackFile = state.trackFile,
                      let track = tracks[trackFile] else {continue}
                
                item = TrackHistoryItem(track: track,
                                        addCount: .init(persistentState: state.addCount) ?? .init(),
                                        playCount: .init(persistentState: state.playCount) ?? .init())
                
            case .playlistFile:
                
                guard let playlistFile = state.playlistFile else {continue}
                
                item = PlaylistFileHistoryItem(playlistFile: playlistFile,
                                               addCount: .init(persistentState: state.addCount) ?? .init(),
                                               playCount: .init(persistentState: state.playCount) ?? .init())
                
            case .folder:
                
                guard let folder = state.folder else {continue}
                
                item = FolderHistoryItem(folder: folder,
                                         addCount: .init(persistentState: state.addCount) ?? .init(),
                                         playCount: .init(persistentState: state.playCount) ?? .init())
                
            case .group:
                
                //            if let groupName = state.groupName, let groupType = state.groupType {
                //                item = GroupHistoryItem(groupName: groupName, groupType: groupType, lastEventTime: lastEventTime, addCount: addCount)
                //            }
                break
            }
            
            if let item {
                self.recentItems[item.key] = item
            }
        }
    }
}
