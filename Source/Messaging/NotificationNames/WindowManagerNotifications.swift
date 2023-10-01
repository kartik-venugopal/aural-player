//
//  WindowManagerNotifications.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
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
}
