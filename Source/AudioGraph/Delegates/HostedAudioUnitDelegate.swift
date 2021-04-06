import Cocoa
import AVFoundation
import CoreAudioKit
import AudioToolbox
import CoreAudio

class HostedAudioUnitDelegate: FXUnitDelegate<HostedAudioUnit>, HostedAudioUnitDelegateProtocol {
    
    var name: String {unit.name}
    
    var params: [AUParameterAddress: Float] {unit.params}
    func printParams() {unit.printParams()}
    
    var presets: AudioUnitPresets {unit.presets}
    var supportsUserPresets: Bool {unit.supportsUserPresets}
    
    var factoryPresets: [AudioUnitFactoryPreset] {unit.factoryPresets}
    
    var viewController: AUViewController?
    
    func applyFactoryPreset(_ presetName: String) {
        unit.applyFactoryPreset(presetName)
    }
    
    func presentView(_ handler: @escaping (NSView) -> ()) {
        
        if let viewController = self.viewController {
            
            handler(viewController.view)
            return
        }
        
        unit.auAudioUnit.requestViewController(completionHandler: {viewCon in
            
            if let theViewController = viewCon as? AUViewController {
                
                self.viewController = theViewController
                handler(theViewController.view)
            }
        })
    }
}
