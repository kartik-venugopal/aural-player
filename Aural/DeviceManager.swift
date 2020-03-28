import Cocoa
import AVFoundation

public class DeviceManager {
    
    let outputAudioUnit: AudioUnit
    
    init(_ outputAudioUnit: AudioUnit) {
        self.outputAudioUnit = outputAudioUnit
    }
    
    var allDevices: [AudioDevice] {
        
        var propsize: UInt32 = 0
        
        var address: AudioObjectPropertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioHardwarePropertyDevices),
            mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))
        
        var result: OSStatus = AudioObjectGetPropertyDataSize(AudioObjectID(kAudioObjectSystemObject), &address, UInt32(MemoryLayout<AudioObjectPropertyAddress>.size), nil, &propsize)
        
        if (result != 0) {
            NSLog("Error \(result) from AudioObjectGetPropertyDataSize")
            return []
        }
        
        let numDevices = Int(propsize / UInt32(MemoryLayout<AudioDeviceID>.size))
        
        var devids = [AudioDeviceID]()
        for _ in 0..<numDevices {
            devids.append(AudioDeviceID())
        }
        
        result = AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &propsize, &devids);
        
        if (result != 0) {
            NSLog("Error \(result) from AudioObjectGetPropertyData")
            return []
        }
        
        var devices: [AudioDevice] = []
        
        for i in 0..<numDevices {
            
            let audioDevice = AudioDevice(deviceID: devids[i])
            
            if let name = audioDevice.name, audioDevice.hasOutput, !name.contains("CADefaultDeviceAggregate") {
                devices.append(audioDevice)
            }
        }
        
        return devices
    }
    
    var systemDevice: AudioDevice {
        return allDevices.first(where: {$0.id == systemDeviceId})!
    }
    
    private var systemDeviceId: AudioDeviceID {
        
        var curDeviceId: AudioDeviceID? = kAudioObjectUnknown
        var size: UInt32 = 0
        
        var inputDeviceAOPA: AudioObjectPropertyAddress =
            AudioObjectPropertyAddress(mSelector:
                kAudioHardwarePropertyDefaultOutputDevice,
                                       mScope: kAudioObjectPropertyScopeGlobal,
                                       mElement:
                kAudioObjectPropertyElementMaster)
        
        // Get size
        AudioObjectGetPropertyDataSize(UInt32(kAudioObjectSystemObject), &inputDeviceAOPA, 0, nil, &size)
        
        // Get device
        AudioObjectGetPropertyData(UInt32(kAudioObjectSystemObject), &inputDeviceAOPA, 0, nil, &size, &curDeviceId)
        
        return curDeviceId!
    }
    
    var outputDevice: AudioDevice {
        
        get {
            
            var outDeviceID: AudioDeviceID = 0
            var sizeOfAudioDevId = UInt32(MemoryLayout<AudioDeviceID>.size)
            let error = AudioUnitGetProperty(outputAudioUnit, kAudioOutputUnitProperty_CurrentDevice, kAudioUnitScope_Global, 0, &outDeviceID, &sizeOfAudioDevId)
            
            if error == 0
            {
                // If the current device is "CADefaultDeviceAggregate", it is actually equivalent to systemDevice
                let devices: [AudioDevice] = allDevices
                return devices.first(where: {$0.id == outDeviceID}) ?? devices.first(where: {$0.id == systemDeviceId})!
            }
            
            NSLog("Error getting current audio output device, errorCode=", error)
            return systemDevice
        }
        
        set(newDevice) {
            
            var outDeviceID: AudioDeviceID = newDevice.id
            let sizeOfAudioDevId = UInt32(MemoryLayout<AudioDeviceID>.size)
            let error = AudioUnitSetProperty(outputAudioUnit, kAudioOutputUnitProperty_CurrentDevice, kAudioUnitScope_Global, 0, &outDeviceID, sizeOfAudioDevId)
            
            if error > 0
            {
                NSLog("Error setting audio output device to: ", newDevice.name!, ", errorCode=", error)
            }
        }
    }
}
