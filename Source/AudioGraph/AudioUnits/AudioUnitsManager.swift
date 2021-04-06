import AVFoundation

class AudioUnitsManager {
    
    private let componentManager: AVAudioUnitComponentManager = AVAudioUnitComponentManager.shared()
    
    private var components: [AVAudioUnitComponent] = []
    private let componentsBlackList: Set<String> = ["AURoundTripAAC", "AUNetSend"]
    
    init() {
        
        self.components = componentManager.components { component, _ in
            
            return component.typeName == AVAudioUnitTypeEffect &&
                component.hasCustomView &&
                !self.componentsBlackList.contains(component.name)
        }
    }
    
    var audioUnits: [AVAudioUnitComponent] {components}
    var numberOfAudioUnits: Int {components.count}
    
    func component(ofType componentSubType: OSType) -> AVAudioUnitComponent? {
        return components.first(where: {$0.audioComponentDescription.componentSubType == componentSubType})
    }
}
