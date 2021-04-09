import AVFoundation
import CoreAudioKit
import Cocoa

class HostedAUNode: AVAudioUnitEffect {
    
    private var avComponent: AVAudioUnitComponent!
    
    var componentType: OSType {auAudioUnit.componentDescription.componentType}
    var componentSubType: OSType {auAudioUnit.componentDescription.componentSubType}
    
    var componentName: String {auAudioUnit.audioUnitName!}
    var componentVersion: String {avComponent.versionString}
    var componentManufacturerName: String {avComponent.manufacturerName}
    
    var paramsTree: AUParameterTree? {auAudioUnit.parameterTree}
    private var bypassStateObservers: [AUNodeBypassStateObserver] = []
    
    var params: [AUParameterAddress: Float] {
        
        get {
            
            var dict: [AUParameterAddress: Float] = [:]
            
            for param in paramsTree?.allParameters ?? [] {
                dict[param.address] = param.value
            }
            
            return dict
        }
        
        set(newParams) {
            
            for (address, value) in newParams {
                paramsTree?.parameter(withAddress: address)?.value = value
            }
        }
    }
    
    convenience init(forComponent component: AVAudioUnitComponent) {
        
        self.init(audioComponentDescription: component.audioComponentDescription)
        self.avComponent = component

        auAudioUnit.addObserver(self, forKeyPath: "shouldBypassEffect", options: .init(), context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "shouldBypassEffect" {
            bypassStateObservers.forEach {$0.nodeBypassStateChanged(auAudioUnit.shouldBypassEffect)}
        }
    }
    
    func addBypassStateObserver(_ observer: AUNodeBypassStateObserver) {
        bypassStateObservers.append(observer)
    }
    
    func savePreset(_ presetName: String) -> AUAudioUnitPreset? {
        
        if #available(OSX 10.15, *), auAudioUnit.supportsUserPresets {
            
            let preset = AUAudioUnitPreset()
            preset.name = presetName
            preset.number = -1 * (auAudioUnit.userPresets.count + 1)
            
            do {
                
                try auAudioUnit.saveUserPreset(preset)
                return preset
                
            } catch {
                print("\nFailed to save user preset '\(presetName)': \(error)")
            }
            
        } else {
            print("\nUser presets not supported for audio unit: \(name)")
        }
        
        return nil
    }
    
    func applyPreset(_ number: Int) {
        
        if #available(OSX 10.15, *), let preset = auAudioUnit.userPresets.first(where: {$0.number == number}) {
            auAudioUnit.currentPreset = preset
        }
    }
    
    func printParams() {
        
        print("\n")
        
        for param in self.auAudioUnit.parameterTree?.allParameters ?? [] {
            print("\(param.identifier):\(param.displayName)=\(param.value)")
        }
        
        print("-------------------\n")
    }
}

protocol AUNodeBypassStateObserver {
    
    func nodeBypassStateChanged(_ nodeIsBypassed: Bool)
}
