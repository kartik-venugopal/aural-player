import AVFoundation

class AudioUnitsManager {
    
    private let componentManager: AVAudioUnitComponentManager = AVAudioUnitComponentManager.shared()
    
    private var components: [AVAudioUnitComponent] = []
    
    private let componentsBlackList: Set<String> = ["AUNewPitch", "AURoundTripAAC", "AUNetSend"]
    private let acceptedComponentTypes: Set<OSType> = [kAudioUnitType_Effect,
                                                       kAudioUnitType_MusicEffect, kAudioUnitType_Panner]
    
    init() {
        
        self.components = componentManager.components { component, _ in
            
            return self.acceptedComponentTypes.contains(component.audioComponentDescription.componentType) &&
                component.hasCustomView &&
                !self.componentsBlackList.contains(component.name)
            
        }.sorted(by: {$0.name < $1.name})
    }
    
    var audioUnits: [AVAudioUnitComponent] {components}
    var numberOfAudioUnits: Int {components.count}
    
    func component(ofType type: OSType, andSubType subType: OSType) -> AVAudioUnitComponent? {
        return components.first(where: {$0.audioComponentDescription.componentType == type && $0.audioComponentDescription.componentSubType == subType})
    }
}
