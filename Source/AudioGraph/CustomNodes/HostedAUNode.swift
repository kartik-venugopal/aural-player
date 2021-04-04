import AVFoundation
import CoreAudioKit
import Cocoa

class HostedAUNode: AVAudioUnitEffect {
    
    var componentSubType: OSType {auAudioUnit.componentDescription.componentSubType}
    var audioUnitName: String {auAudioUnit.audioUnitName!}
    
    // Identifier -> Parameter
    var paramsMap: [String: AUParameter] = [:]
    
    var viewController: NSViewController?

    override init(audioComponentDescription: AudioComponentDescription) {
        
        super.init(audioComponentDescription: audioComponentDescription)
        
        if let params = self.auAudioUnit.parameterTree?.allParameters {
            
            for param in params {
                paramsMap[param.identifier] = param
            }
        }
    }
    
    func setParams(_ params: [String: Float]) {
        
        for (paramId, value) in params {
            paramsMap[paramId]?.value = value
        }
    }
    
    func setParam(key: String, value: Float) {
        
        if let param = paramsMap[key] {
            param.value = value
        }
        
        refresh()
    }
    
    func printParams() {
        
        for param in paramsMap.values {
            print("\(param.identifier):\(param.displayName)=\(param.value)")
        }
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
