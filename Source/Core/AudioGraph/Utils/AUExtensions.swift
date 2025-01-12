//
//  AUExtensions.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AudioToolbox

///
/// An assortment of extensions to make it easier for clients to work with audio output hardware devices
/// and register for notifications such as render callbacks and changes in device properties.
///

let sizeOfDouble: UInt32 = UInt32(MemoryLayout<Double>.size)

extension AudioUnit {
    
    func registerRenderCallback(inProc: @escaping AURenderCallback, inProcUserData: UnsafeMutableRawPointer?) {
        AudioUnitAddRenderNotify(self, inProc, inProcUserData)
    }
    
    func removeRenderCallback(inProc: @escaping AURenderCallback, inProcUserData: UnsafeMutableRawPointer?) {
        AudioUnitRemoveRenderNotify(self, inProc, inProcUserData)
    }
    
    var currentDevice: AudioDeviceID {
        
        get {
            
            var deviceId: AudioDeviceID = 0
            var sizeOfProp: UInt32 = sizeOfDeviceId
            _ = AudioUnitGetProperty(self, kAudioOutputUnitProperty_CurrentDevice, kAudioUnitScope_Global, 0, &deviceId, &sizeOfProp)
            
            return deviceId
        }
        
        set {
            
            var deviceId: AudioDeviceID = newValue
            AudioUnitSetProperty(self, kAudioOutputUnitProperty_CurrentDevice, kAudioUnitScope_Global, 0, &deviceId, sizeOfDeviceId)
        }
    }
    
    func registerDeviceChangeCallback(inProc: @escaping AudioUnitPropertyListenerProc, inProcUserData: UnsafeMutableRawPointer?) {
        AudioUnitAddPropertyListener(self, kAudioOutputUnitProperty_CurrentDevice, inProc, inProcUserData)
    }
    
    func removeDeviceChangeCallback(inProc: @escaping AudioUnitPropertyListenerProc, inProcUserData: UnsafeMutableRawPointer?) {
        AudioUnitRemovePropertyListenerWithUserData(self, kAudioOutputUnitProperty_CurrentDevice, inProc, inProcUserData)
    }
    
    var sampleRate: Double {
        
        get {
            
            var sampleRate: Double = 0
            var sizeOfProp: UInt32 = sizeOfDouble
            _ = AudioUnitGetProperty(self, kAudioDevicePropertyActualSampleRate, kAudioUnitScope_Global, 0, &sampleRate, &sizeOfProp)
            
            return sampleRate
        }
    }
    
    func registerSampleRateChangeCallback(inProc: @escaping AudioUnitPropertyListenerProc, inProcUserData: UnsafeMutableRawPointer?) {
        AudioUnitAddPropertyListener(self, kAudioUnitProperty_SampleRate, inProc, inProcUserData)
    }
    
    func removeSampleRateChangeCallback(inProc: @escaping AudioUnitPropertyListenerProc, inProcUserData: UnsafeMutableRawPointer?) {
        AudioUnitRemovePropertyListenerWithUserData(self, kAudioUnitProperty_SampleRate, inProc, inProcUserData)
    }
    
    var bufferFrameSize: UInt32 {
        
        get {
            
            var bufferSize: UInt32 = 0
            var sizeOfProp: UInt32 = sizeOfUInt32
            _ = AudioUnitGetProperty(self, kAudioDevicePropertyBufferFrameSize, kAudioUnitScope_Global, 0, &bufferSize, &sizeOfProp)
            
            return bufferSize
        }
        
        set {
            
            var newBufferSize: UInt32 = newValue
            AudioUnitSetProperty(self, kAudioDevicePropertyBufferFrameSize, kAudioUnitScope_Global, 0, &newBufferSize, sizeOfUInt32)
        }
    }
    
    var maxFramesPerSlice: UInt32 {
        
        get {
            
            var maxFrames: UInt32 = 0
            var sizeOfProp: UInt32 = sizeOfUInt32
            _ = AudioUnitGetProperty(self, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0, &maxFrames, &sizeOfProp)
            
            return maxFrames
        }
        
        set {
            
            var maxFrames: UInt32 = newValue
            AudioUnitSetProperty(self, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0, &maxFrames, sizeOfUInt32)
        }
    }
}

extension AudioObjectID {
    
    static let systemAudioObject: AudioObjectID = AudioObjectID(kAudioObjectSystemObject)
    
    static let hardwareDefaultOutputDevicePropertyAddress: AudioObjectPropertyAddress =
    AudioObjectPropertyAddress(outputPropertyWithSelector: kAudioHardwarePropertyDefaultOutputDevice)
    
    static let hardwareDevicesPropertyAddress: AudioObjectPropertyAddress =
        AudioObjectPropertyAddress(globalPropertyWithSelector: kAudioHardwarePropertyDevices)
    
    var defaultOutputDevice: AudioDeviceID {
        
        var curDeviceId: AudioDeviceID = kAudioObjectUnknown
        var propAddress: AudioObjectPropertyAddress = Self.hardwareDefaultOutputDevicePropertyAddress
        var sizeOfProp: UInt32 = 0
        
        AudioObjectGetPropertyDataSize(self, &propAddress, 0, nil, &sizeOfProp)
        AudioObjectGetPropertyData(self, &propAddress, 0, nil, &sizeOfProp, &curDeviceId)
        
        return curDeviceId
    }
    
    var devices: [AudioDeviceID] {
        
        get {
            
            var propSize: UInt32 = 0
            var propAddress: AudioObjectPropertyAddress = Self.hardwareDevicesPropertyAddress
            
            AudioObjectGetPropertyDataSize(self, &propAddress, sizeOfPropertyAddress, nil, &propSize)
            
            let numDevices = Int(propSize / sizeOfDeviceId)
            var deviceIds: [AudioDeviceID] = Array(repeating: AudioDeviceID(), count: numDevices)
            
            AudioObjectGetPropertyData(self, &propAddress, 0, nil, &propSize, &deviceIds)
            
            return deviceIds
        }
    }
    
    func registerDevicesPropertyListener(_ handler: @escaping () -> Void, queue: DispatchQueue) {
        
        var propAddress: AudioObjectPropertyAddress = Self.hardwareDevicesPropertyAddress
        AudioObjectAddPropertyListenerBlock(self, &propAddress, queue, {_, _ in
            handler()
        })
    }
}

extension AudioObjectPropertyAddress {
    
    init(globalPropertyWithSelector selector: AudioObjectPropertySelector) {
        self.init(mSelector: selector, mScope: kAudioObjectPropertyScopeGlobal, mElement: kAudioObjectPropertyElementMaster)
    }
    
    init(outputPropertyWithSelector selector: AudioObjectPropertySelector) {
        self.init(mSelector: selector, mScope: kAudioObjectPropertyScopeOutput, mElement: kAudioObjectPropertyElementMaster)
    }
}

let sizeOfPropertyAddress: UInt32 = UInt32(MemoryLayout<AudioObjectPropertyAddress>.size)
let sizeOfDeviceId: UInt32 = UInt32(MemoryLayout<AudioDeviceID>.size)
let sizeOfCFStringOptional: UInt32 = UInt32(MemoryLayout<CFString?>.size)
let sizeOfUInt32: UInt32 = UInt32(MemoryLayout<UInt32>.size)
