//
//  ApplicationNotifications.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// Notifications that pertain to the application life-cycle.
///
extension Notification.Name {
    
    struct Application {
        
        // Signifies that the application has finished launching
        static let launched = Notification.Name("application_launched")
        
        // Signifies that the application has been reopened after being launched previously.
        static let reopened = Notification.Name("application_reopened")
        
        // Signifies that the application is about to exit/terminate, allowing observers
        // to save any state or perform any kind of shutdown or cleanup prior to exiting.
        static let willExit = Notification.Name("application_willExit")
    }
}
