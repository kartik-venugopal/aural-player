//
//  ApplicationNotifications.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

extension Notification.Name {
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Notifications published by the application (i.e. app delegate). They represent different lifecycle stages/events.
    
    // Signifies that the application has finished launching
    static let application_launched = Notification.Name("application_launched")
    
    // Signifies that the application has been reopened after being launched previously.
    static let application_reopened = Notification.Name("application_reopened")
    
    // Signifies that the application is about to exit/terminate, allowing observers
    // to save any state or perform any kind of shutdown or cleanup prior to exiting.
    static let application_willExit = Notification.Name("application_willExit")
}
