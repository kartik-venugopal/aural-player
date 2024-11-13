//
//  PlayQueueUIPersistentState.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

struct PlayQueueUIPersistentState: Codable {
    
    let currentView: PlayQueueView?
    let searchSettings: SearchSettings?
}
