//
//  InternalDeviceList.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
#if os(macOS)

import AudioToolbox

///
/// Encapsulates a collection of audio output hardware devices available on the local system, and provides
/// functions for convenient searching of devices.
///
/// This class is for internal use by **DeviceManager** and is not exposed to clients of **DeviceManager**.
///
class InternalDeviceList {
    
    private let systemAudioObject: AudioObjectID = .systemAudioObject
    
    // id -> Device
    private var knownDevices: [AudioDeviceID: AudioDevice] = [:]
    
    private(set) var devices: [AudioDevice] = []
    
    // id -> Device
    private var devicesMap: [AudioDeviceID: AudioDevice] = [:]
    
    private var lastRebuildTime: Double = 0
    private static let minRebuildTimeSeparation: Double = 0.1
    
    // Used to ensure that simultaneous reads/writes cannot occur.
    private let lock: ExclusiveAccessSemaphore = ExclusiveAccessSemaphore()
    
    private lazy var messenger = Messenger(for: self)
    
    init() {
        
        rebuildList()
        
        // Devices list change listener
        systemAudioObject.registerDevicesPropertyListener({[weak self] in self?.rebuildList()}, queue: .global(qos: .utility))
    }
    
    private func rebuildList() {
     
        lock.executeAfterWait {
            
            // Determine when the list was last rebuilt. If the time interval between
            // now and that timestamp is less than a threshold, return without doing anything.
            // This is necessary to prevent repeated (redundant) rebuilding of the list in response
            // to duplicate notifications.
            let now = nowCFTime()
            if (now - self.lastRebuildTime) < Self.minRebuildTimeSeparation {return}
            
            let deviceIds: [AudioDeviceID] = systemAudioObject.devices
            
            self.lastRebuildTime = now
            
            let oldDeviceIds = Set(devices.map {$0.id})
            
            devices.removeAll()
            devicesMap.removeAll()
            
            for deviceId in deviceIds {
                
                guard let device = knownDevices[deviceId] ?? AudioDevice(deviceId: deviceId) else {continue}
                
                devices.append(device)
                devicesMap[deviceId] = device
                
                if knownDevices[deviceId] == nil {
                    knownDevices[deviceId] = device
                }
            }
            
            let newDeviceIds = Set(devices.map {$0.id})
            
            if newDeviceIds != oldDeviceIds {
                messenger.publish(.deviceManager_deviceListUpdated)
            }
        }
    }
    
    func deviceById(_ id: AudioDeviceID) -> AudioDevice? {

        lock.produceValueAfterWait {
            devicesMap[id]
        }
    }
}

#endif
