//
//  RepeatAndShuffleModesCommandNotification.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

struct RepeatAndShuffleModesCommandNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .Player.setRepeatAndShuffleModes
    
    let repeatMode: RepeatMode
    let shuffleMode: ShuffleMode
}
