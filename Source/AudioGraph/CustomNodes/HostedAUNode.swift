import AVFoundation
import CoreAudioKit
import Cocoa

class HostedAUNode: AVAudioUnitEffect {
    
    var componentSubType: OSType {auAudioUnit.componentDescription.componentSubType}
    var audioUnitName: String {auAudioUnit.audioUnitName!}
    
    var paramsTree: AUParameterTree? {auAudioUnit.parameterTree}
    
    var viewController: NSViewController?
    
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
                paramsTree?.parameter(withAddress: address)?.setValue(value, originator: nil)
            }
        }
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
