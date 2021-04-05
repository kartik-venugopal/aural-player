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
                paramsTree?.parameter(withAddress: address)?.value = value
            }
        }
    }
    
    func printParams() {
        
        print("\n")
//        for param in paramsMap.values {
//            print("\(param.identifier):\(param.displayName)=\(param.value)")
//        }
        
        for param in self.auAudioUnit.parameterTree?.allParameters ?? [] {
            print("\(param.identifier):\(param.displayName)=\(param.value)")
        }
        
        print("-------------------\n")
    }
    
    func refresh() {
        viewController?.view.setNeedsDisplay(viewController!.view.bounds)
    }
    
    func presentView(_ handler: @escaping (NSView) -> ()) {
        
        auAudioUnit.requestViewController(completionHandler: {viewCon in
            
            if let theViewController = viewCon {
                
                self.viewController = theViewController
                handler(theViewController.view)
            }
        })
    }
}
