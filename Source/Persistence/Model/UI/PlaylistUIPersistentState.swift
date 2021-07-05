//
//  PlaylistUIPersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

struct PlaylistUIPersistentState: Codable {
    
    let view: PlaylistType?
}

extension PlaylistViewState {
    
    static func initialize(_ persistentState: PlaylistUIPersistentState?) {
        currentView = persistentState?.view ?? PlaylistViewDefaults.currentView
    }
    
    static var persistentState: PlaylistUIPersistentState {
        PlaylistUIPersistentState(view: currentView)
    }
}
