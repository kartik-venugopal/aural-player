//
//  HistoryProtocol.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

/*
    Contract for performing CRUD operations on the History model
 */
protocol HistoryProtocol {
    
    // Retrieves all items from the Recently added list, in chronological order
    func allRecentlyAddedItems() -> [AddedItem]

    // Adds items to the Recently added list. Each "time" argument represents the time the corresponding item was added to the playlist.
    func addRecentlyAddedItem(_ file: URL, _ name: String, _ time: Date)
    
    func addRecentlyAddedItem(_ file: URL, _ time: Date)
    
    func addRecentlyAddedItem(_ track: Track, _ time: Date)
    
    // Retrieves all items from the Recently played list, in chronological order
    func allRecentlyPlayedItems() -> [PlayedItem]
    
    func mostRecentlyPlayedItem() -> PlayedItem?
    
    // Adds an item, as a track, to the Recently played list. The "time" argument represents the time the corresponding item was played.
    func addRecentlyPlayedItem(_ item: Track, _ time: Date)
    
    // Adds an item, as a filesystem file, to the Recently played list. The "time" argument represents the time the corresponding item was played.
    func addRecentlyPlayedItem(_ file: URL, _ name: String, _ time: Date)
    
    // Resizes all history lists with the given sizes
    func resizeLists(_ recentlyAddedListSize: Int, _ recentlyPlayedListSize: Int)
    
    func clearAllHistory()
    
    func deleteItem(_ item: PlayedItem)
    
    func deleteItem(_ item: AddedItem)
}
