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
    
    var selectedRows: IndexSet = .empty
    
    init(persistentState: PlayQueueUIPersistentState?) {
        currentView = persistentState?.currentView ?? PlayQueueUIDefaults.currentView
    }
    
    var persistentState: PlayQueueUIPersistentState {
        PlayQueueUIPersistentState(currentView: currentView)
    }
}

enum PlayQueueView: Int, Codable {
    
    case simple
    case expanded
}

struct PlayQueueUIDefaults {
    
    static let currentView: PlayQueueView = .simple
}
