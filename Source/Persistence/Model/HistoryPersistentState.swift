//
//  HistoryPersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

struct HistoryPersistentState: Codable {
    
    let recentlyAdded: [HistoryItemPersistentState]?
    let recentlyPlayed: [HistoryItemPersistentState]?
}

struct HistoryItemPersistentState: Codable {
    
    let file: URL?
    let name: String?
    let time: Date?
}

extension HistoryDelegate: PersistentModelObject {
    
    var persistentState: HistoryPersistentState {
        
        let recentlyAdded = allRecentlyAddedItems().map {HistoryItemPersistentState(file: $0.file, name: $0.displayName, time: $0.time)}
        let recentlyPlayed = allRecentlyPlayedItems().map {HistoryItemPersistentState(file: $0.file, name: $0.displayName, time: $0.time)}
        
        return HistoryPersistentState(recentlyAdded: recentlyAdded, recentlyPlayed: recentlyPlayed)
    }
}
