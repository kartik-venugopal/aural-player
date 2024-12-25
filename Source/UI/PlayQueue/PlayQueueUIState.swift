//
//  PlayQueueUIState.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class PlayQueueUIState: PersistentModelObject {
    
    // The current play queue view type displayed within the tab group.
    var currentView: PlayQueueView
    
    var isShowingSearch: Bool = false       // Transient field
    var searchSettings: SearchSettings
    
    var selectedRows: IndexSet = .empty
    
    init(persistentState: PlayQueueUIPersistentState?) {
        
        currentView = persistentState?.currentView ?? PlayQueueUIDefaults.currentView
        searchSettings = persistentState?.searchSettings ?? .init()
    }
    
    var persistentState: PlayQueueUIPersistentState {
        PlayQueueUIPersistentState(currentView: currentView, searchSettings: searchSettings)
    }
}

enum PlayQueueView: Int, CaseIterable, Codable {
    
    case simple
    case expanded
    case tabular
}

struct PlayQueueUIDefaults {
    
    static let currentView: PlayQueueView = .simple
}
