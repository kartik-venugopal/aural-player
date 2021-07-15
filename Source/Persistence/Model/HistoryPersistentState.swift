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

///
/// Persistent state for the **History** lists
/// (recently added and recently played).
///
/// - SeeAlso: `AddedItem`
/// - SeeAlso: `PlayedItem`
///
struct HistoryPersistentState: Codable {
    
    let recentlyAdded: [HistoryItemPersistentState]?
    let recentlyPlayed: [HistoryItemPersistentState]?
}

///
/// Persistent state for a single item in the **History** lists
/// (recently added and recently played).
///
/// - SeeAlso: `AddedItem`
/// - SeeAlso: `PlayedItem`
///
struct HistoryItemPersistentState: Codable {
    
    let file: URLPath?
    let name: String?
    let time: DateString?
    
    init(item: HistoryItem) {
        
        self.file = item.file.path
        self.name = item.displayName
        self.time = item.time.serializableString()
    }
}
