//
//  HistoryProtocol.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A functional contract for access to the chronologically ordered track lists:
/// 1. tracks recently added to the play queue
/// 2. tracks recently played
///
/// Acts as a middleman between the UI and the History lists,
/// providing a simplified interface / facade for the UI layer to manipulate the History lists
/// and add / play tracks from those lists.
///
/// - SeeAlso: `AddedItem`
/// - SeeAlso: `PlayedItem`
///
protocol HistoryProtocol: HistoryConsumerProtocol, TrackInitComponent {
    
    // Retrieves all items from the Recently added list, in chronological order
    var allRecentItems: [HistoryItem] {get}
    
    var numberOfItems: Int {get}
    
    subscript(_ index: Int) -> HistoryItem {get}
    
    // Plays a given item.
    func playItem(_ item: HistoryItem)
    
    func resizeRecentItemsList(to newListSize: Int)
    
    func clearAllHistory()
    
    func deleteItem(_ item: HistoryItem)
    
    func markLastPlaybackPosition(_ position: TimeInterval)
    
    var lastPlaybackPosition: TimeInterval {get}
    
    var lastPlayedItem: TrackHistoryItem? {get}
    
    var canResumeLastPlayedSequence: Bool {get}
    
    func resumeLastPlayedSequence()
    
    func trackItem(forTrack track: Track) -> TrackHistoryItem?
    
    func playCount(forTrack track: Track) -> Int
    
    func lastPlayedTime(forTrack track: Track) -> Date?
    
    // TODO: getPlayStats(), getAddStats()
}

protocol HistoryConsumerProtocol {
    
    func fileSystemItemsAdded(urls: [URL])
    
    func tracksAdded(_ tracks: [Track])
}
