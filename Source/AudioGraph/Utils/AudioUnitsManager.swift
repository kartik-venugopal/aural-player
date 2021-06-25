//
//  AudioUnitsManager.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

///
/// Utility class that determines which Audio Units (AU) plug-ins that are supported by the app are installed on the local system.
///
class AudioUnitsManager {
    
    private let componentManager: AVAudioUnitComponentManager = AVAudioUnitComponentManager.shared()
    
    private var components: [AVAudioUnitComponent] = []
    
    private let componentsBlackList: Set<String> = ["AUNewPitch", "AURoundTripAAC", "AUNetSend"]
    private let acceptedComponentTypes: Set<OSType> = [kAudioUnitType_Effect,
                                                       kAudioUnitType_MusicEffect, kAudioUnitType_Panner]
    
    init() {
        refreshComponentsList()
    }
    
    var audioUnits: [AVAudioUnitComponent] {components}
    
    func audioUnit(ofType type: OSType, andSubType subType: OSType) -> AVAudioUnitComponent? {
        
        components.first(where: {$0.audioComponentDescription.componentType == type &&
                            $0.audioComponentDescription.componentSubType == subType})
    }
    
    // TODO: Should this be refreshed every time the components list is requested ???
    func refreshComponentsList() {
        
        self.components = componentManager.components {component, _ in
            
            return self.acceptedComponentTypes.contains(component.audioComponentDescription.componentType) &&
                component.hasCustomView &&
                !self.componentsBlackList.contains(component.name)
            
        }.sorted(by: {$0.name < $1.name})
    }
}
