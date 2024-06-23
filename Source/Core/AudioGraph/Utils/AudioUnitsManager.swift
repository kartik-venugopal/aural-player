//
//  AudioUnitsManager.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

///
/// Utility class that determines which Audio Units (AU) plug-ins that are supported by the app are installed on the local system.
///
class AudioUnitsManager {
    
    private let componentManager: AVAudioUnitComponentManager = .shared()
    
    let audioUnits: [AVAudioUnitComponent]
    
    private static let componentsBlackList: Set<String> = ["AURoundTripAAC", "AUNetSend"]
    private static let acceptedComponentTypes: Set<OSType> = [kAudioUnitType_Effect, kAudioUnitType_MusicEffect, kAudioUnitType_Panner]
    
    init() {
        
        self.audioUnits = componentManager.components {component, _ in
            
            Self.acceptedComponentTypes.contains(component.componentType) &&
                !Self.componentsBlackList.contains(component.name)
            
        }.sorted(by: {$0.name < $1.name})
    }
    
    func audioUnit(ofType type: OSType, andSubType subType: OSType) -> AVAudioUnitComponent? {
        audioUnits.first(where: {$0.componentType == type && $0.componentSubType == subType})
    }
}
