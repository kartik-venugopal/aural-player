import Cocoa

class GradientOptionsRadioButtonGroup: NSControl {
    
    @IBOutlet weak var btnGradientEnabled: NSButton!
    @IBOutlet weak var btnGradientDarken: NSButton!
    @IBOutlet weak var btnGradientBrighten: NSButton!
    
    var gradientType: GradientType {
        
        get {
            
            if btnGradientEnabled.isOn {
                return btnGradientDarken.isOn ? .darken : .brighten
            }
            
            return .none
        }
        
        set(newValue) {
            
            switch newValue {
                
            case .none:
                
                btnGradientEnabled.off()
                btnGradientDarken.on()
                btnGradientBrighten.off()
                
            case .darken:
                
                btnGradientEnabled.on()
                btnGradientDarken.on()
                btnGradientBrighten.off()
                
            case .brighten:
                
                btnGradientEnabled.on()
                btnGradientDarken.off()
                btnGradientBrighten.on()
            }
            
            [btnGradientDarken, btnGradientBrighten].forEach({$0?.enableIf(btnGradientEnabled.isOn)})
        }
    }
}
