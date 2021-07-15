//
//  AudioDevice.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

///
/// Encapsulates a single audio hardware device.
///
public class AudioDevice {
    
    static var deviceUIDPropertyAddress = AudioObjectPropertyAddress(globalPropertyWithSelector: kAudioDevicePropertyDeviceUID)
    
    static var modelUIDPropertyAddress = AudioObjectPropertyAddress(globalPropertyWithSelector: kAudioDevicePropertyModelUID)
    
    static var namePropertyAddress = AudioObjectPropertyAddress(globalPropertyWithSelector: kAudioDevicePropertyDeviceNameCFString)
    
    static var manufacturerPropertyAddress = AudioObjectPropertyAddress(globalPropertyWithSelector: kAudioDevicePropertyDeviceManufacturerCFString)
    
    static var streamConfigPropertyAddress = AudioObjectPropertyAddress(outputPropertyWithSelector: kAudioDevicePropertyStreamConfiguration)
    
    static var dataSourcePropertyAddress = AudioObjectPropertyAddress(outputPropertyWithSelector: kAudioDevicePropertyDataSource)
    
    static var transportTypePropertyAddress = AudioObjectPropertyAddress(outputPropertyWithSelector: kAudioDevicePropertyTransportType)
    
    // The unique device ID relative to other devices currently available. Used to set the output device (is NOT persistent).
    let id: AudioDeviceID
    
    // Persistent unique identifer of this device (not user-friendly)
    let uid: String
    
    let modelUID: String?
    
    // User-friendly (and persistent) display name string for this device
    let name: String
    
    // User-friendly (and persistent) manufacturer name string for this device
    let manufacturer: String?
    
    let channelCount: Int
    
    let dataSource: String?
    let transportType: String?
    let isConnectedViaBluetooth: Bool
    
    init?(deviceId: AudioDeviceID) {
        
        guard let name = deviceId.getCFStringProperty(addressPtr: &Self.namePropertyAddress),
            !name.contains("CADefaultDeviceAggregate"),
            let uid = deviceId.getCFStringProperty(addressPtr: &Self.deviceUIDPropertyAddress) else {
            
            return nil
        }
        
        let channelCount: Int = {
            
            var size: UInt32 = sizeOfCFStringOptional
            var result: OSStatus = AudioObjectGetPropertyDataSize(deviceId, &Self.streamConfigPropertyAddress, 0, nil, &size)
            if result != 0 {return 0}
            
            let bufferList = UnsafeMutablePointer<AudioBufferList>.allocate(capacity: Int(sizeOfCFStringOptional))
            result = AudioObjectGetPropertyData(deviceId, &Self.streamConfigPropertyAddress, 0, nil, &size, bufferList)
            if result != 0 {return 0}
            
            let buffers = UnsafeMutableAudioBufferListPointer(bufferList)
            
            return Int((0..<buffers.count).map{buffers[$0]}.reduce(0, {(channelCountSoFar: UInt32, buffer: AudioBuffer) -> UInt32 in channelCountSoFar + buffer.mNumberChannels}))
        }()
        
        // We are only interested in output devices
        if channelCount <= 0 {return nil}
        
        self.id = deviceId
        self.uid = uid
        self.modelUID = deviceId.getCFStringProperty(addressPtr: &Self.modelUIDPropertyAddress)
        
        self.name = name
        self.manufacturer = deviceId.getCFStringProperty(addressPtr: &Self.manufacturerPropertyAddress)
        
        self.channelCount = channelCount
        
        self.dataSource = deviceId.getCodeProperty(addressPtr: &Self.dataSourcePropertyAddress)
        self.transportType = deviceId.getCodeProperty(addressPtr: &Self.transportTypePropertyAddress)
        self.isConnectedViaBluetooth = transportType?.lowercased() == "blue"
    }
}

fileprivate extension AudioDeviceID {
    
    func getCFStringProperty(addressPtr: UnsafePointer<AudioObjectPropertyAddress>) -> String? {
        
        var prop: CFString? = nil
        var size: UInt32 = sizeOfCFStringOptional
        
        let result: OSStatus = AudioObjectGetPropertyData(self, addressPtr, 0, nil, &size, &prop)
        return result == noErr ? prop as String? : nil
    }
    
    func getCodeProperty(addressPtr: UnsafePointer<AudioObjectPropertyAddress>) -> String? {
        
        var prop: UInt32 = 0
        var size: UInt32 = sizeOfUInt32
        
        let result: OSStatus = AudioObjectGetPropertyData(self, addressPtr, 0, nil, &size, &prop)
        return result == noErr ? (prop as FourCharCode).toString() : nil
    }
}
