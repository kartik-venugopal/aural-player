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
                
                print("Class for VC: \(theViewController.view.className)")
                
                let mir = Mirror(reflecting: theViewController)
                for child in mir.children {
                    print("Member: \(child.label!)")
                }
                
                self.viewController = theViewController
                handler(theViewController.view)
            }
        })
    }
    
    override func applyPreset(_ presetName: String) {
        
        super.applyPreset(presetName)
        refreshView()
    }
    
    func refreshView() {
        
        if self.viewController != nil {
            print("Refreshing view ...")
        }
        
//        viewController?.view.hide()
        let superView = viewController?.view.superview
        viewController?.view.removeFromSuperview()
        viewController!.view.needsDisplay = true
        
        sleep(3)
//        viewController?.view.show()
        superView?.addSubview(viewController!.view)
        viewController!.view.anchorToView(superView!)
    }
}
