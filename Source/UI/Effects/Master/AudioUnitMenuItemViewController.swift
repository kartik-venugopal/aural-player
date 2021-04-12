import Cocoa

class AudioUnitMenuItemViewController: NSViewController {
    
    override var nibName: String? {return "AudioUnitMenuItem"}
    
    @IBOutlet weak var lblName: EffectsUnitTriStateLabel!
    
    override func viewDidLoad() {
        lblName.font = FontSchemes.systemScheme.effects.unitFunctionFont
    }
}

class AudioUnitMenuItemView: NSView {
    
    @IBOutlet weak var btnBypass: EffectsUnitTriStateBypassButton!
    @IBOutlet weak var lblName: EffectsUnitTriStateLabel!
    
    var unitName: String! {
        
        didSet {
            lblName.stringValue = unitName
        }
    }
    
    var audioUnit: HostedAudioUnitDelegateProtocol! {
        
        didSet {
            
            if let theUnit = audioUnit {
            
                btnBypass.stateFunction = theUnit.stateFunction
                lblName.stateFunction = theUnit.stateFunction
            }
        }
    }
    
    @IBAction func bypassAction(_ sender: EffectsUnitTriStateBypassButton) {
        
        _ = audioUnit.toggleState()
        
        btnBypass.updateState()
        lblName.updateState()
    }
}
