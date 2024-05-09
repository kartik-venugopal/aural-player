//
//  HistoryPreferences.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Encapsulates all user preferences pertaining to the track history lists.
///
class HistoryPreferences {
    
    lazy var recentItemsListSize: OptionalUserPreference<Int> = .init(defaultsKey: "\(Self.keyPrefix).recentItems.listSize")
    
    private static let keyPrefix: String = "history"
    
    private typealias Defaults = PreferencesDefaults.History
    
    init() {
    }
}

// TODO: ???
enum TrackListMenuItemAction: String, Codable {
    
    case enqueue
    case enqueueAndPlay
}
