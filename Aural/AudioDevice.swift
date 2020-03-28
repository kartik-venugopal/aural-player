import Cocoa
import AVFoundation

public class AudioDevice {
    
    let id: AudioDeviceID
    
    let uid: String?
    let name: String?
    let hasOutput: Bool
    
    init(deviceID: AudioDeviceID) {
        
        self.id = deviceID
        
        self.uid = {
            
            var address:AudioObjectPropertyAddress = AudioObjectPropertyAddress(
                mSelector:AudioObjectPropertySelector(kAudioDevicePropertyDeviceUID),
                mScope:AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
                mElement:AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))
            
            var name:CFString? = nil
            var propsize:UInt32 = UInt32(MemoryLayout<CFString?>.size)
            let result:OSStatus = AudioObjectGetPropertyData(deviceID, &address, 0, nil, &propsize, &name)
            
            return result != 0 ? nil : name as String?
        }()
        
        self.name = {
            
            var address:AudioObjectPropertyAddress = AudioObjectPropertyAddress(
                mSelector:AudioObjectPropertySelector(kAudioDevicePropertyDeviceNameCFString),
                mScope:AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
                mElement:AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))
            
            var name:CFString? = nil
            var propsize:UInt32 = UInt32(MemoryLayout<CFString?>.size)
            let result:OSStatus = AudioObjectGetPropertyData(deviceID, &address, 0, nil, &propsize, &name)
            
            return result != 0 ? nil : name as String?
        }()
        
        self.hasOutput = {
            
            var address:AudioObjectPropertyAddress = AudioObjectPropertyAddress(
                mSelector:AudioObjectPropertySelector(kAudioDevicePropertyStreamConfiguration),
                mScope:AudioObjectPropertyScope(kAudioDevicePropertyScopeOutput),
                mElement:0)
            
            var propsize:UInt32 = UInt32(MemoryLayout<CFString?>.size);
            var result:OSStatus = AudioObjectGetPropertyDataSize(deviceID, &address, 0, nil, &propsize);
            if (result != 0) {
                return false;
            }
            
            let bufferList = UnsafeMutablePointer<AudioBufferList>.allocate(capacity:Int(propsize))
            result = AudioObjectGetPropertyData(deviceID, &address, 0, nil, &propsize, bufferList);
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
        }()
    }
}
