import Cocoa

class HostedAudioUnitDelegate: FXUnitDelegate<HostedAudioUnit>, HostedAudioUnitDelegateProtocol {
    
    var name: String {unit.name}
    
    var params: [String: Float] {unit.params}
    
    var presets: AudioUnitPresets {unit.presets}
    
    var viewController: NSViewController?
    
    func presentView(_ handler: @escaping (NSView) -> ()) {
        
        if let viewController = self.viewController {
            
            handler(viewController.view)
            return
        }
        
        unit.auAudioUnit.requestViewController(completionHandler: {viewCon in
            
            if let theViewController = viewCon {
                
                self.viewController = theViewController
                handler(theViewController.view)
            }
        })
    }
}
