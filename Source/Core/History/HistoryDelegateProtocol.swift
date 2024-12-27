//
//  HistoryDelegateProtocol.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A functional contract for a delegate allowing access to the chronologically ordered track lists:
/// 1. tracks recently added to the playlist
/// 2. tracks recently played
///
/// Acts as a middleman between the UI and the History lists,
/// providing a simplified interface / facade for the UI layer to manipulate the History lists
/// and add / play tracks from those lists.
///
/// - SeeAlso: `AddedItem`
/// - SeeAlso: `PlayedItem`
///
protocol HistoryDelegateProtocol {
    
    // Retrieves all items from the Recently added list, in chronological order
    var allRecentItems: [HistoryItem] {get}
    
    var numberOfItems: Int {get}
    
    func historyItem(at index: Int) -> HistoryItem
    
    // Plays a given item.
    func playItem(_ item: HistoryItem)
    
    func resizeRecentItemsList(to newListSize: Int)
    
    func clearAllHistory()
    
    func deleteItem(_ item: HistoryItem)
    
    func markLastPlaybackPosition(_ position: Double)
    
    var lastPlaybackPosition: Double {get}
    
    var lastPlayedItem: TrackHistoryItem? {get}
    
    var canResumeLastPlayedSequence: Bool {get}
    
    func resumeLastPlayedSequence()
    
    func playCount(forTrack track: Track) -> Int
    
    func lastEventTime(forTrack track: Track) -> Date?
    
    // TODO: getPlayStats(), getAddStats()
}
