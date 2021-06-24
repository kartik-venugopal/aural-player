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
class AudioDevicePersistentState: PersistentStateProtocol {
    
    let name: String
    let uid: String
    
    init(name: String, uid: String) {
        
        self.name = name
        self.uid = uid
    }
    
    required init?(_ map: NSDictionary) {
        
        guard let name = map["name", String.self],
              let uid = map["uid", String.self] else {return nil}
        
        self.name = name
        self.uid = uid
    }
}
