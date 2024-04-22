//
//  EnqueueAndPlayNowCommand.swift
//  Aural-macOS
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

struct EnqueueAndPlayNowCommand: NotificationPayload {
    
    let notificationName: Notification.Name = .PlayQueue.enqueueAndPlayNow
    let tracks: [Track]
    let clearPlayQueue: Bool
}

struct LoadAndPlayNowCommand: NotificationPayload {
    
    let notificationName: Notification.Name = .PlayQueue.loadAndPlayNow
    let files: [URL]
    let clearPlayQueue: Bool
}
