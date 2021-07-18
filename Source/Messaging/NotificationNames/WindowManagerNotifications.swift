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

///
/// Notifications pertaining to the **Window Manager**.
///
extension Notification.Name {
    
    // MARK: Notifications published by the window manager.
    
    // Signifies that the window layout has just been changed, i.e. windows have been shown/hidden and/or rearranged.
    static let windowManager_layoutChanged = Notification.Name("windowManager_layoutChanged")
    
    // MARK: Window layout commands
    
//    // Commands the window manager to make the main window the key (frontmost) window.
//    static let windowManager_makeMainWindowKey = Notification.Name("windowManager_makeMainWindowKey")
//    
//    // Commands the window manager to make the playlist window the key (frontmost) window.
//    static let windowManager_makePlaylistWindowKey = Notification.Name("windowManager_makePlaylistWindowKey")
//    
//    // Commands the window manager to add the given window as a child of the main window.
//    static let windowManager_addChildWindow = Notification.Name("windowManager_addChildWindow")
//    
//    // Commands the window manager to show the given window centered wrt. the main window.
//    static let windowManager_showWindowCenteredOverMainWindow = Notification.Name("windowManager_showWindowCenteredOverMainWindow")
//    
//    // Commands the window manager to show/hide the playlist window.
//    static let windowManager_togglePlaylistWindow = Notification.Name("windowManager_togglePlaylistWindow")
//
//    // Commands the window manager to show/hide the effects window.
//    static let windowManager_toggleEffectsWindow = Notification.Name("windowManager_toggleEffectsWindow")
//    
//    // Commands the window manager to show/hide the chapters list window.
//    static let windowManager_toggleChaptersListWindow = Notification.Name("windowManager_toggleChaptersListWindow")
//    
//    // Commands the window manager to show the chapters list window.
//    static let windowManager_showChaptersListWindow = Notification.Name("windowManager_showChaptersListWindow")
//    
//    // Commands the window manager to hide the chapters list window.
//    static let windowManager_hideChaptersListWindow = Notification.Name("windowManager_hideChaptersListWindow")
//    
//    // Commands the window manager to show/hide the visualizer window.
//    static let windowManager_toggleVisualizerWindow = Notification.Name("windowManager_toggleVisualizerWindow")
//    
//    // Commands the window manager to show/hide the tune browser window.
//    static let windowManager_toggleTuneBrowserWindow = Notification.Name("windowManager_toggleTuneBrowserWindow")
//    
//    // Commands the window manager to apply a window layout with the given name.
//    static let windowManager_applyNamedLayout = Notification.Name("windowManager_applyNamedLayout")
//    
//    // Commands the window manager to apply the given window layout.
//    static let windowManager_applyLayout = Notification.Name("windowManager_applyLayout")
}
