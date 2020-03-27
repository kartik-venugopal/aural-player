import Cocoa
import AVFoundation

public class AudioDevice {
    
    var audioDeviceID: AudioDeviceID
    
    init(deviceID: AudioDeviceID) {
        self.audioDeviceID = deviceID
    }
    
    var hasOutput: Bool {
        
        get {
            var address:AudioObjectPropertyAddress = AudioObjectPropertyAddress(
                mSelector:AudioObjectPropertySelector(kAudioDevicePropertyStreamConfiguration),
                mScope:AudioObjectPropertyScope(kAudioDevicePropertyScopeOutput),
                mElement:0)
            
            var propsize:UInt32 = UInt32(MemoryLayout<CFString?>.size);
            var result:OSStatus = AudioObjectGetPropertyDataSize(self.audioDeviceID, &address, 0, nil, &propsize);
            if (result != 0) {
                return false;
            }
            
            let bufferList = UnsafeMutablePointer<AudioBufferList>.allocate(capacity:Int(propsize))
            result = AudioObjectGetPropertyData(self.audioDeviceID, &address, 0, nil, &propsize, bufferList);
            if (result != 0) {
                return false
            }
            
            let buffers = UnsafeMutableAudioBufferListPointer(bufferList)
            for bufferNum in 0..<buffers.count {
                if buffers[bufferNum].mNumberChannels > 0 {
                    return true
                }
            }
            
            return false
        }
    }
    
    var uid:String? {
        
        get {
            var address:AudioObjectPropertyAddress = AudioObjectPropertyAddress(
                mSelector:AudioObjectPropertySelector(kAudioDevicePropertyDeviceUID),
                mScope:AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
                mElement:AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))
            
            var name:CFString? = nil
            var propsize:UInt32 = UInt32(MemoryLayout<CFString?>.size)
            let result:OSStatus = AudioObjectGetPropertyData(self.audioDeviceID, &address, 0, nil, &propsize, &name)
            if (result != 0) {
                return nil
            }
            
            return name as String?
        }
    }
    
    var name:String? {
        get {
            var address:AudioObjectPropertyAddress = AudioObjectPropertyAddress(
                mSelector:AudioObjectPropertySelector(kAudioDevicePropertyDeviceNameCFString),
                mScope:AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
                mElement:AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))
            
            var name:CFString? = nil
            var propsize:UInt32 = UInt32(MemoryLayout<CFString?>.size)
            let result:OSStatus = AudioObjectGetPropertyData(self.audioDeviceID, &address, 0, nil, &propsize, &name)
            if (result != 0) {
                return nil
            }
            
            return name as String?
        }
    }
}


public class DeviceManager {
    
    static func getAllDevices() -> [AudioDevice] {
        
        var propsize: UInt32 = 0
        
        var address: AudioObjectPropertyAddress = AudioObjectPropertyAddress(
            mSelector: AudioObjectPropertySelector(kAudioHardwarePropertyDevices),
            mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
            mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))
        
        var result: OSStatus = AudioObjectGetPropertyDataSize(AudioObjectID(kAudioObjectSystemObject), &address, UInt32(MemoryLayout<AudioObjectPropertyAddress>.size), nil, &propsize)
        
        if (result != 0) {
            print("Error \(result) from AudioObjectGetPropertyDataSize")
            return []
        }
        
        let numDevices = Int(propsize / UInt32(MemoryLayout<AudioDeviceID>.size))
        
        var devids = [AudioDeviceID]()
        for _ in 0..<numDevices {
            devids.append(AudioDeviceID())
        }
        
        result = AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &propsize, &devids);
        
        if (result != 0) {
            print("Error \(result) from AudioObjectGetPropertyData")
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
    
    static func getSystemDevice() -> AudioDevice {

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
        
        let devices: [AudioDevice] = DeviceManager.getAllDevices()
        return devices.first(where: {$0.audioDeviceID == curDeviceId!})!
    }
}
