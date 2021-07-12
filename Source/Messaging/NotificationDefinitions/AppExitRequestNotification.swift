//
//  AppExitRequestNotification.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

// Request from the application to its components to perform an exit. Receiving components will determine
// whether or not the app may exit, by submitting appropriate responses.
class AppExitRequestNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .application_exitRequest
    
    // A collection of individual responses from all observers, indicating whether or not the app may exit.
    // NOTE - This collection will be empty at the time this notification is dispatched. Observers will
    // populate the collection as and when they receive the notification. A true value signifies it is ok
    // to exit, and false signifies not ok to exit.
    private var responses: [Bool] = []
    
    // The aggregate result of all the received responses, i.e whether or not the app may safely exit.
    // true means ok to exit, false otherwise.
    var okToExit: Bool {
        return !responses.contains(false)
    }
    
    // Accepts a single response from an observer, and adds it to the responses collection for later use.
    func acceptResponse(okToExit: Bool) {
        responses.append(okToExit)
    }
}
