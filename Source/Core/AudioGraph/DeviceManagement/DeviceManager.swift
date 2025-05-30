//
//  DeviceManager.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

fileprivate var deviceChangeHandler: () -> Void = {}

///
/// Utility class that provides a simple facade of operations dealing with audio output hardware devices,
/// hiding interactions with low-level CoreAudio functions.
///
/// Used as a helper by the Audio Graph to get/set the current audio output device for the app.
///
public class DeviceManager {
    
    private let systemAudioObject: AudioObjectID = .systemAudioObject
    
    // The AudioUnit underlying AVAudioEngine's output node (used to set the output device)
    var outputAudioUnit: AudioUnit
    
    private let list: InternalDeviceList
    
    init(outputAudioUnit: AudioUnit) {
        
        self.outputAudioUnit = outputAudioUnit
        self.list = InternalDeviceList()
        self.outputDeviceId = systemDeviceId
        
        deviceChangeHandler = self.outputDeviceChanged
        
        // System output device change listener
        outputAudioUnit.registerDeviceChangeCallback(inProc: deviceChanged, inProcUserData: Unmanaged.passUnretained(self).toOpaque())
    }
    
    // A listing of all available audio output devices
    var allDevices: [AudioDevice] {
        list.devices
    }
    
    var numberOfDevices: Int {
        list.devices.count
    }
    
    var systemDevice: AudioDevice {
        list.deviceById(systemDeviceId) ?? AudioDevice(deviceId: systemDeviceId)!
    }
    
    // The AudioDeviceID of the audio output device currently being used by the OS
    private var systemDeviceId: AudioDeviceID {systemAudioObject.defaultOutputDevice}
    
    var outputDevice: AudioDevice {
        
        get {list.deviceById(outputDeviceId) ?? AudioDevice(deviceId: outputDeviceId) ?? systemDevice}
        set {outputDeviceId = newValue.id}
    }
    
    var indexOfOutputDevice: Int {
        
        let outputDeviceId = self.outputDeviceId
        return list.devices.firstIndex(where: {$0.id == outputDeviceId})!
    }
    
    // The variable used to get/set the application's audio output device
    private var outputDeviceId: AudioDeviceID {
        
        get {outputAudioUnit.currentDevice}
        
        set(newDeviceId) {
            
            if list.hasDeviceById(newDeviceId), outputDeviceId != newDeviceId {
                outputAudioUnit.currentDevice = newDeviceId
            }
        }
    }
    
    private func outputDeviceChanged() {
        Messenger.publish(.deviceManager_defaultDeviceChanged)
    }
    
    var outputDeviceBufferSize: Int {
        
        get {Int(outputAudioUnit.bufferFrameSize)}
        
        // TODO: [MED] How to determine if this is safe / allowed / within the allowed range ?
        set {outputAudioUnit.bufferFrameSize = UInt32(newValue)}
    }
    
    var outputDeviceSampleRate: Double {outputAudioUnit.sampleRate}
    
    var maxFramesPerSlice: Int {
        
        get {Int(outputAudioUnit.maxFramesPerSlice)}
        set {outputAudioUnit.maxFramesPerSlice = UInt32(newValue)}
    }
}

fileprivate func deviceChanged(inRefCon: UnsafeMutableRawPointer,
                               inUnit: AudioUnit,
                               inID: AudioUnitPropertyID,
                               inScope: AudioUnitScope,
                               inElement: AudioUnitElement) {
    
    deviceChangeHandler()
}

extension Notification.Name {
    
    // ----------------------------------------------------------------------------------------
    
    // MARK: Notifications published by the application (i.e. app delegate). They represent different lifecycle stages/events.
    
    // Signifies that the list of audio output devices has been updated.
    static let deviceManager_deviceListUpdated = Notification.Name("deviceManager_deviceListUpdated")
    
    // Signifies that the default system output device has changed.
    static let deviceManager_defaultDeviceChanged = Notification.Name("deviceManager_defaultDeviceChanged")
}
