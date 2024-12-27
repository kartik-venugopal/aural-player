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
import OrderedCollections

class PlayQueueUIState: PersistentModelObject {
    
    var displayedColumns: OrderedDictionary<String, PlayQueueTableColumn> = .init()
    
    // The current play queue view type displayed within the tab group.
    var currentView: PlayQueueView
    
    var isShowingSearch: Bool = false       // Transient field
    var searchSettings: SearchSettings
    
    var selectedRows: IndexSet = .empty
    
    static let defaultSortColumn: String = "name"
    var sortColumn: String
    
    static let defaultSortIsAscending: Bool = true
    var sortIsAscending: Bool
    
    init(persistentState: PlayQueueUIPersistentState?) {
        
        currentView = persistentState?.currentView ?? PlayQueueUIDefaults.currentView
        searchSettings = persistentState?.searchSettings ?? .init()
        
        for colState in persistentState?.displayedColumns ?? [] {
            
            if let id = colState.id {
                displayedColumns[id] = PlayQueueTableColumn(persistentState: colState)
            }
        }
        
        sortColumn = persistentState?.sortColumn ?? Self.defaultSortColumn
        sortIsAscending = persistentState?.sortIsAscending ?? Self.defaultSortIsAscending
    }
    
    var persistentState: PlayQueueUIPersistentState {
        
        .init(currentView: currentView, searchSettings: searchSettings,
              displayedColumns: displayedColumns.values.map {PlayQueueTableColumnPersistentState(id: $0.id, width: $0.width)},
              sortColumn: sortColumn,
              sortIsAscending: sortIsAscending)
    }
}

struct PlayQueueTableColumn {
    
    let id: String
    let width: CGFloat
    
    init(id: String, width: CGFloat) {
        
        self.id = id
        self.width = width
    }
    
    init?(persistentState: PlayQueueTableColumnPersistentState) {

        guard let id = persistentState.id, let width = persistentState.width else {return nil}

        self.id = id
        self.width = width
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
