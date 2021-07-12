//
//  AudioGraphNotifications.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

extension Notification.Name {
    
    // MARK: Notifications published by the audio graph (i.e. audio engine).
    
    // Signifies that the audio output device for the audio engine has changed.
    // eg. when the user plugs headphones in or out of the system, or connects to
    // a new set of speakers.
    static let audioGraph_outputDeviceChanged = Notification.Name("audioGraph_outputDeviceChanged")
    
    static let audioGraph_preGraphChange = Notification.Name("audioGraph_preGraphChange")
    
    static let audioGraph_graphChanged = Notification.Name("audioGraph_graphChanged")
}
