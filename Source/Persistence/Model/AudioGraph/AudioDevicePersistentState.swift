//
//  AudioDevicePersistentState.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Persistent state for a single audio output device.
///
/// - SeeAlso: `AudioDevice`
///
struct AudioDevicePersistentState: Codable {
    
    let name: String?
    let uid: String?
}
