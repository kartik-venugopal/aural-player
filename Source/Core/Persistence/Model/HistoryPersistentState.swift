//
//  HistoryPersistentState.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Persistent state for the **History** lists
/// (recently added and recently played).
///
/// - SeeAlso: `AddedItem`
/// - SeeAlso: `PlayedItem`
///
struct HistoryPersistentState: Codable {
    
    let recentItems: [HistoryItemPersistentState]?
    let lastPlaybackPosition: Double?
    let shuffleSequence: ShuffleSequencePersistentState?
    
    var mostRecentTrackItem: HistoryItemPersistentState? {
        recentItems?.last(where: {$0.itemType == .track})
    }
    
    init(recentItems: [HistoryItemPersistentState], lastPlaybackPosition: Double, shuffleSequence: ShuffleSequencePersistentState?) {
        
        self.recentItems = recentItems
        self.lastPlaybackPosition = lastPlaybackPosition
        self.shuffleSequence = shuffleSequence
    }
    
    init(legacyPersistentState: LegacyHistoryPersistentState?) {
        
        self.recentItems = legacyPersistentState?.recentlyPlayed?.map {HistoryItemPersistentState(legacyPersistentState: $0)}
        self.lastPlaybackPosition = legacyPersistentState?.lastPlaybackPosition
        self.shuffleSequence = nil
    }
}

enum HistoryPersistentItemType: String, Codable {
    
    case track
    case playlistFile
    case folder
    case group
}

///
/// Persistent state for a single item in the **History** lists
/// (recently added and recently played).
///
/// - SeeAlso: `AddedItem`
/// - SeeAlso: `PlayedItem`
///
struct HistoryItemPersistentState: Codable {
    
    let itemType: HistoryPersistentItemType?

    let addCount: HistoryEventCounterPersistentState?
    let playCount: HistoryEventCounterPersistentState?
    
    var trackFile: URL? = nil
    
    var playlistFile: URL? = nil
    
    var folder: URL? = nil
    
    var groupName: String? = nil
//    var groupType: GroupType? = nil
    
    init?(item: HistoryItem) {
        
        self.addCount = .init(counter: item.addCount)
        self.playCount = .init(counter: item.playCount)
        
        if let trackHistoryItem = item as? TrackHistoryItem {
            
            self.itemType = .track
            self.trackFile = trackHistoryItem.track.file
            
            return
        }
        
        if let playlistFileHistoryItem = item as? PlaylistFileHistoryItem {
            
            self.itemType = .playlistFile
            self.playlistFile = playlistFileHistoryItem.playlistFile
            
            return
        }
        
        if let folderHistoryItem = item as? FolderHistoryItem {
            
            self.itemType = .folder
            self.folder = folderHistoryItem.folder
            
            return
        }
        
//        if let groupHistoryItem = item as? GroupHistoryItem {
//            
//            self.itemType = .group
//            self.groupName = groupHistoryItem.groupName
//            self.groupType = groupHistoryItem.groupType
//            
//            return
//        }
        
        return nil
    }
    
    init(legacyPersistentState: LegacyHistoryItemPersistentState) {
        
        self.itemType = .track
        
        self.addCount = .init(lastEventTime: legacyPersistentState.dateFromTimestamp, eventCount: 1)
        self.playCount = .init()
        
        if let filePath = legacyPersistentState.file {
            self.trackFile = URL(fileURLWithPath: filePath)
        } else {
            self.trackFile = nil
        }
    }
}

struct HistoryEventCounterPersistentState: Codable {
    
    let lastEventTime: Date?
    let eventCount: Int?
    
    init(counter: HistoryEventCounter) {
        
        self.lastEventTime = counter.lastEventTime
        self.eventCount = counter.eventCount
    }
    
    init(lastEventTime: Date? = nil, eventCount: Int? = nil) {
        
        self.lastEventTime = lastEventTime
        self.eventCount = eventCount
    }
}
