//
//  HistoryDelegate.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

/*
    Concrete implementation of HistoryDelegateProtocol
 */
class HistoryDelegate: HistoryDelegateProtocol, NotificationSubscriber {
    
    // The actual underlying History model object
    private let history: HistoryProtocol
    
    // Delegate used to perform CRUD on the playlist
    private let playlist: PlaylistDelegateProtocol
    
    // Delegate used to perform playback
    private let player: PlaybackDelegateProtocol
    
    var lastPlayedTrack: Track?
    
    let backgroundQueue: DispatchQueue = .global(qos: .background)
    
    let subscriberId: String = "HistoryDelegate"
    
    init(persistentState: HistoryPersistentState?, _ history: HistoryProtocol,
         _ playlist: PlaylistDelegateProtocol, _ player: PlaybackDelegateProtocol) {
        
        self.history = history
        self.playlist = playlist
        self.player = player
        
        // Restore the history model object from persistent state
        
        persistentState?.recentlyAdded?.reversed().forEach {item in
            
            guard let path = item.file, let timeString = item.time,
                  let date = Date.fromString(timeString) else {return}
            
            let file = URL(fileURLWithPath: path)
            history.addRecentlyAddedItem(file, item.name ?? file.lastPathComponent, date)
        }
        
        persistentState?.recentlyPlayed?.reversed().forEach {item in
            
            guard let path = item.file, let timeString = item.time,
                  let date = Date.fromString(timeString) else {return}
            
            let file = URL(fileURLWithPath: path)
            history.addRecentlyPlayedItem(file, item.name ?? file.lastPathComponent, date)
        }
        
        Messenger.publish(.history_updated)
        
        Messenger.subscribeAsync(self, .history_itemsAdded, self.itemsAdded(_:), queue: backgroundQueue)
        
        Messenger.subscribeAsync(self, .player_trackTransitioned, self.trackPlayed(_:),
                                 filter: {msg in msg.playbackStarted},
                                 queue: backgroundQueue)
    }
    
    func allRecentlyAddedItems() -> [AddedItem] {
        return history.allRecentlyAddedItems()
    }
    
    func allRecentlyPlayedItems() -> [PlayedItem] {
        return history.allRecentlyPlayedItems()
    }
    
    func addItem(_ item: URL) throws {
        
        if !item.exists {
            throw FileNotFoundError(item)
        }
        
        playlist.addFiles([item])
    }
    
    func playItem(_ item: URL, _ playlistType: PlaylistType) throws {
        
        do {
            
            // First, find or add the given file
            if let newTrack = try playlist.findOrAddFile(item) {
            
                // Play it
                player.play(newTrack)
            }
            
        } catch {
            
            if let fnfError = error as? FileNotFoundError {
                
                // Log and rethrow error
                NSLog("Unable to play History item. Details: %@", fnfError.message)
                throw fnfError
            }
        }
    }
    
    func deleteItem(_ item: PlayedItem) {
        history.deleteItem(item)
    }
    
    func deleteItem(_ item: AddedItem) {
        history.deleteItem(item)
    }
    
    func resizeLists(_ recentlyAddedListSize: Int, _ recentlyPlayedListSize: Int) {
        
        history.resizeLists(recentlyAddedListSize, recentlyPlayedListSize)
        Messenger.publish(.history_updated)
    }
    
    func clearAllHistory() {
        history.clearAllHistory()
    }
    
    func compareChronologically(_ track1: URL, _ track2: URL) -> ComparisonResult {
        
        let allHistory = history.allRecentlyPlayedItems()
        
        let index1 = allHistory.firstIndex(where: {$0.file == track1})
        let index2 = allHistory.firstIndex(where: {$0.file == track2})
        
        if index1 == nil && index2 == nil {
            return .orderedSame
        }
        
        if index1 != nil && index2 != nil {
            // Assume cannot be equal (that would imply duplicates in history list)
            return index1! > index2! ? .orderedDescending : .orderedAscending
        }
        
        if index1 != nil {
            return .orderedAscending
        }
        
        return .orderedDescending
    }
    
    // Whenever a track is played by the player, add an entry in the "Recently played" list
    func trackPlayed(_ notification: TrackTransitionNotification) {
        
        if let newTrack = notification.endTrack {
        
            lastPlayedTrack = newTrack
            history.addRecentlyPlayedItem(newTrack.file, newTrack.displayName, Date())
            Messenger.publish(.history_updated)
        }
    }
    
    // Whenever items are added to the playlist, add entries to the "Recently added" list
    func itemsAdded(_ files: [URL]) {
        
        let now = Date()
        
        for file in files {
            
            if let track = playlist.findFile(file) {
                
                // Track
                history.addRecentlyAddedItem(track, now)
                
            } else {
                
                // Folder or playlist
                history.addRecentlyAddedItem(file, now)
            }
        }
        
        Messenger.publish(.history_updated)
    }
    
    var persistentState: HistoryPersistentState {
        
        let recentlyAdded = allRecentlyAddedItems().map {HistoryItemPersistentState(item: $0)}
        let recentlyPlayed = allRecentlyPlayedItems().map {HistoryItemPersistentState(item: $0)}
        
        return HistoryPersistentState(recentlyAdded: recentlyAdded, recentlyPlayed: recentlyPlayed)
    }
}
