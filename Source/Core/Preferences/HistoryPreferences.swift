//
//  HistoryPreferences.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Encapsulates all user preferences pertaining to the track history lists.
///
class HistoryPreferences {
    
    @OptionalUserPreference(key: "history.recentItems.listSize")
    var recentItemsListSize: Int?
    
    private static let keyPrefix: String = "history"
    
    private typealias Defaults = PreferencesDefaults.History
    
    init(legacyPreferences: LegacyHistoryPreferences?) {
        legacyPreferences?.deleteAll()
    }
}

// TODO: ???
enum TrackListMenuItemAction: String, Codable {
    
    case enqueue
    case enqueueAndPlay
}
