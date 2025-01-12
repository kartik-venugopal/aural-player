//
//  PlayQueueUIPersistentState.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

struct PlayQueueUIPersistentState: Codable {
    
    let currentView: PlayQueueView?
    let searchSettings: SearchSettings?
    
    let displayedColumns: [PlayQueueTableColumnPersistentState]?
    let sortColumn: String?
    let sortIsAscending: Bool?
}

struct PlayQueueTableColumnPersistentState: Codable {
    
    let id: String?
    let width: CGFloat?
}
