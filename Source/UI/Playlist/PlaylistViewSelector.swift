//
//  PlaylistViewSelector.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

// Helps in filtering command notifications sent to playlist views, i.e. "selects" a playlist view
// as the intended recipient of a command notification.
struct PlaylistViewSelector {
    
    // TODO: Make this an OptionSet
    
    // A specific playlist view, if any, that should be exclusively selected.
    // nil value means all playlist views are selected.
    let specificView: PlaylistType?
    
    private init(_ specificView: PlaylistType? = nil) {
        self.specificView = specificView
    }
    
    // Whether or not a given playlist view is included in the selection specified by this object.
    // If a specific view was specified when creating this object, this method will return true
    // only for that playlist view. Otherwise, it will return true for all playlist views.
    func includes(_ view: PlaylistType) -> Bool {
        return specificView == nil || specificView == view
    }
    
    // A selector instance that specifies a selection of all playlist views.
    static let allViews: PlaylistViewSelector = PlaylistViewSelector()
    
    // Factory method that creates a selector for a specific playlist view.
    static func forView(_ view: PlaylistType) -> PlaylistViewSelector {
        return PlaylistViewSelector(view)
    }
}
