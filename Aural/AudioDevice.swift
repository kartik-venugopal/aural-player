import Cocoa
import AVFoundation

/*
    Encapsulates a single audio hardware device
 */
public class AudioDevice {
    
    // The unique device ID relative to other devices currently available. Used to set the output device (is NOT persistent).
    let id: AudioDeviceID
    
    // Persistent unique identifer of this device (not user-friendly)
    let uid: String?
    
    // User-friendly (and persistent) display name string of this device
    let name: String?
    
    // Whether or not this device is capable of output
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
