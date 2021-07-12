//
//  ShowAudioUnitEditorCommandNotification.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

// Command from the playlist search dialog to the playlist, to show (i.e. select) a specific search result within the playlist.
struct ShowAudioUnitEditorCommandNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .auEffectsUnit_showEditor

    // The audio unit that is to be edited.
    let audioUnit: HostedAudioUnitDelegateProtocol
}
