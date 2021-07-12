//
//  WindowManagerNotifications.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

extension Notification.Name {
    
    // MARK: Notifications published by the window manager.
    
    // Signifies that the window layout has just been changed, i.e. windows have been shown/hidden and/or rearranged.
    static let windowManager_layoutChanged = Notification.Name("windowManager_layoutChanged")
    
    // MARK: Window layout commands
    
    // Commands the window manager to show/hide the playlist window
    static let windowManager_togglePlaylistWindow = Notification.Name("windowManager_togglePlaylistWindow")

    // Commands the window manager to show/hide the effects window
    static let windowManager_toggleEffectsWindow = Notification.Name("windowManager_toggleEffectsWindow")
}
