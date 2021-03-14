import AudioToolbox

class DeviceList {
    
    private let systemAudioObject: AudioObjectID = .systemAudioObject
    
    // id -> Device
    private var knownDevices: [AudioDeviceID: AudioDevice] = [:]
    
    private(set) var devices: [AudioDevice] = []
    
    // id -> Device
    private var devicesMap: [AudioDeviceID: AudioDevice] = [:]
    
    private var lastRebuildTime: Double = 0
    
    // Used to ensure that simultaneous reads/writes cannot occur.
    private let semaphore = DispatchSemaphore(value: 1)
    
    init() {
        
        rebuildList()
        
        // Devices list change listener
        systemAudioObject.registerDevicesPropertyListener({self.rebuildList()}, queue: DispatchQueue.global(qos: .utility))
    }
    
    private func rebuildList() {
     
        semaphore.wait()
        defer {semaphore.signal()}
        
        let now = CFAbsoluteTimeGetCurrent()
        if (now - self.lastRebuildTime) < 0.1 {return}
        
        let deviceIds: [AudioDeviceID] = systemAudioObject.devices
        
        self.lastRebuildTime = now
        
        devices.removeAll()
        devicesMap.removeAll()
        
        for deviceId in deviceIds {
            
            if let device = knownDevices[deviceId] ?? AudioDevice(deviceId: deviceId) {
                
                devices.append(device)
                devicesMap[deviceId] = device
                
                if knownDevices[deviceId] == nil {
                    knownDevices[deviceId] = device
                }
            }
        }
        
        Messenger.publish(.deviceManager_deviceListUpdated)
    }
    
    func deviceById(_ id: AudioDeviceID) -> AudioDevice? {

        semaphore.wait()
        defer {semaphore.signal()}
        
        return devicesMap[id]
    }
    
    func deviceByUID(_ uid: String) -> AudioDevice? {
        
        semaphore.wait()
        defer {semaphore.signal()}
        
        return devices.first(where: {$0.uid == uid})
    }
}
