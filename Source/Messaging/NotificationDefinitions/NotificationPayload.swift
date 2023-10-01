//
//  NotificationPayload.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// A contract for payload objects dispatched by **Messenger**.
///
protocol NotificationPayload {
    
    // The name of the associated Notification.
    var notificationName: Notification.Name {get}
}
