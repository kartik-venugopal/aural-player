import Cocoa

/*
    Utility control that encapsulates a set of radio buttons and a check button that together determine the state of a color gradient applied to the system color scheme, i.e. whether or not the gradient is enabled and if so, what type of gradient.
 
    This facilitates operations like undo/redo which need to modify multiple check/radio buttons in one bulk operation.
 */
class GradientOptionsRadioButtonGroup: NSControl {
    
    // Check button (enabled or disabled)
    @IBOutlet weak var btnGradientEnabled: NSButton!
    
    // Radio buttons (different gradient types)
    @IBOutlet weak var btnGradientDarken: NSButton!
    @IBOutlet weak var btnGradientBrighten: NSButton!
    
    var gradientType: GradientType {
        
        get {
            
            // Determines a GradientType value based on the states of the buttons
            
            if btnGradientEnabled.isOn {
                return btnGradientDarken.isOn ? .darken : .brighten
            }
            
            return .none
        }
        
        set(newValue) {
            
            // Sets the states of the buttons depending on a GradientType value
            
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
