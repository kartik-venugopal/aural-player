//
//  AudioDevicePersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

/*
    Encapsulates an audio output device (remembered device)
 */
struct AudioDevicePersistentState: Codable {
    
    let name: String?
    let uid: String?
}
