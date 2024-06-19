//
//  AudioGraphNotifications.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// Notifications published by the audio graph (i.e. audio engine).
///
extension Notification.Name {
    
    struct AudioGraph {
        
        // Signifies that the audio output device for the audio engine has changed.
        // eg. when the user plugs headphones in or out of the system, or connects to
        // a new set of speakers.
        static let outputDeviceChanged = Notification.Name("audioGraph_outputDeviceChanged")
        
        static let preGraphChange = Notification.Name("audioGraph_preGraphChange")
        
        static let graphChanged = Notification.Name("audioGraph_graphChanged")
    }
}
