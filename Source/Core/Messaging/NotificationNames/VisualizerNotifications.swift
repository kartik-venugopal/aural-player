//
//  VisualizerNotifications.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// Notifications pertaining to the **Visualizer**.
///
extension Notification.Name {
    
    // MARK: Visualizer commands sent to all app windows
    
    static let visualizer_showOptions = Notification.Name("visualizer_showOptions")
    static let visualizer_hideOptions = Notification.Name("visualizer_hideOptions")
}
