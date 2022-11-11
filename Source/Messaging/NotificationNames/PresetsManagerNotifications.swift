//
//  PresetsManagerNotifications.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// Notifications pertaining to the **Presets Manager** UI.
///
extension Notification.Name {
    
    // Signifies that the number of rows selected in a NSTableView within the presets manager has changed.
    static let presetsManager_selectionChanged = Notification.Name("presetsManager_selectionChanged")
    
    // MARK: Effects presets manager commands

    // Commands the Effects presets manager to reload all available Effects presets for its currently selected tab
    static let effectsPresetsManager_reload = Notification.Name("effectsPresetsManager_reload")

    // Commands the Effects presets manager to rename the single selected Effects preset in its currently selected tab
    static let effectsPresetsManager_rename = Notification.Name("effectsPresetsManager_rename")

    // Commands the Effects presets manager to delete all selected Effects presets in its currently selected tab
    static let effectsPresetsManager_delete = Notification.Name("effectsPresetsManager_delete")

    // Commands the Effects presets manager to apply the single selected Effects preset in its currently selected tab
    static let effectsPresetsManager_apply = Notification.Name("effectsPresetsManager_apply")
}
