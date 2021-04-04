import AVFoundation
import CoreAudioKit
import Cocoa

class HostedAUNode: AVAudioUnitEffect {
    
    var componentSubType: OSType {auAudioUnit.componentDescription.componentSubType}
    
    // Identifier -> Parameter
    var paramsMap: [String: AUParameter] = [:]
    
    var viewController: NSViewController?
    
    fileprivate override init(audioComponentDescription: AudioComponentDescription) {
        
        super.init(audioComponentDescription: audioComponentDescription)
        
        if let params = self.auAudioUnit.parameterTree?.allParameters {
            
            for param in params {
                paramsMap[param.identifier] = param
            }
        }
    }
    
    static func create(ofType type: OSType) -> HostedAUNode? {
        
        let desc = AudioComponentDescription(componentType: kAudioUnitType_Effect,
                                             componentSubType: type,
                                             componentManufacturer: 0,
                                             componentFlags: 0,
                                             componentFlagsMask: 0)

        guard let component = AVAudioUnitComponentManager.shared().components(matching: desc).first else {return nil}
        return HostedAUNode(audioComponentDescription: component.audioComponentDescription)
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
