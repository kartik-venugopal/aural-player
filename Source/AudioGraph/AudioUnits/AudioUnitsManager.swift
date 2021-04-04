import AVFoundation

class AudioUnitsManager {
    
    private var components: [AVAudioUnitComponent] = []
    let componentsBlackList: Set<String> = ["AUNewPitch", "AURoundTripAAC", "AUNetSend"]
    
    init() {
        
        let desc = AudioComponentDescription(componentType: kAudioUnitType_Effect,
                                             componentSubType: 0,
                                             componentManufacturer: 0,
                                             componentFlags: 0,
                                             componentFlagsMask: 0)

        self.components = AVAudioUnitComponentManager.shared().components(matching: desc)
            .filter {$0.hasCustomView && !componentsBlackList.contains($0.name)}
    }
    
    var audioUnits: [AVAudioUnitComponent] {components}
    var numberOfAudioUnits: Int {components.count}
    
    func component(ofType componentSubType: OSType) -> AVAudioUnitComponent? {
        return components.first(where: {$0.audioComponentDescription.componentSubType == componentSubType})
    }
}
