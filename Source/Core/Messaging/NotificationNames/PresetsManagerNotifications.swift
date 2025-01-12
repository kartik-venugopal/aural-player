//
//  PresetsManagerNotifications.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// Notifications pertaining to the **Presets Manager** UI.
///
extension Notification.Name {
    
    struct PresetsManager {
        
        // Signifies that the number of rows selected in a NSTableView within the presets manager has changed.
        static let selectionChanged = Notification.Name("presetsManager_selectionChanged")
        
        struct Effects {
            
            // MARK: Effects presets manager commands

            // Commands the Effects presets manager to reload all available Effects presets for its currently selected tab
            static let reload = Notification.Name("effectsPresetsManager_reload")
        }
    }
}
