//
//  DeviceManager.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

///
/// Utility class that provides a simple facade of operations dealing with audio output hardware devices,
/// hiding interactions with low-level CoreAudio functions.
///
/// Used as a helper by the Audio Graph to get/set the current audio output device for the app.
///
public class DeviceManager {
    
    private let systemAudioObjectId: AudioObjectID = .systemAudioObject
    
    // The AudioUnit underlying AVAudioEngine's output node (used to set the output device)
    var outputAudioUnit: AudioUnit
    
    private let list: InternalDeviceList
    
    init(outputAudioUnit: AudioUnit) {
        
        self.outputAudioUnit = outputAudioUnit
        self.list = InternalDeviceList()
        self.outputDeviceId = systemDeviceId
    }
    
    // A listing of all available audio output devices
    var allDevices: AudioDeviceList {
        AudioDeviceList(allDevices: list.devices, outputDeviceId: outputDeviceId, systemDeviceId: systemDeviceId)
    }
    
    var systemDevice: AudioDevice {
        list.deviceById(systemDeviceId) ?? AudioDevice(deviceId: systemDeviceId)!
    }
    
    // The AudioDeviceID of the audio output device currently being used by the OS
    private var systemDeviceId: AudioDeviceID {systemAudioObjectId.defaultOutputDevice}
    
    var outputDevice: AudioDevice {
        
        get {list.deviceById(outputDeviceId) ?? AudioDevice(deviceId: outputDeviceId) ?? systemDevice}
        set {outputDeviceId = newValue.id}
    }
    
    // The variable used to get/set the application's audio output device
    private var outputDeviceId: AudioDeviceID {
        
        get {outputAudioUnit.currentDevice}
        
        set(newDeviceId) {
            
            // TODO: Validate that the device still exists ? By doing a lookup in list.map ???
            
            if outputDeviceId != newDeviceId {
                outputAudioUnit.currentDevice = newDeviceId
            }
        }
    }
    
    var outputDeviceBufferSize: Int {
        
        get {Int(outputAudioUnit.bufferFrameSize)}
        
        // TODO: Before setting buffer size, check allowed buffer size range, and clamp the value accordingly ???
        set {outputAudioUnit.bufferFrameSize = UInt32(newValue)}
    }
    
    var outputDeviceSampleRate: Double {outputAudioUnit.sampleRate}
    
    var maxFramesPerSlice: Int {
        
        get {Int(outputAudioUnit.maxFramesPerSlice)}
        set {outputAudioUnit.maxFramesPerSlice = UInt32(newValue)}
    }
}

extension Notification.Name {
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Notifications published by the application (i.e. app delegate). They represent different lifecycle stages/events.
    
    // Signifies that the list of audio output devices has been updated.
    static let deviceManager_deviceListUpdated = Notification.Name("deviceManager_deviceListUpdated")
}
