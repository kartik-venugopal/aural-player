import Cocoa

class WindowCornerRadiusMenuItemView: NSView {
    
    @IBOutlet weak var cornerRadiusStepper: NSStepper!
    @IBOutlet weak var lblCornerRadius: NSTextField!
    
    @IBAction func cornerRadiusStepperAction(_ sender: NSStepper) {
        
        WindowAppearanceState.cornerRadius = CGFloat(cornerRadiusStepper.integerValue)
        lblCornerRadius.stringValue = "\(cornerRadiusStepper.integerValue) px"
        
        Messenger.publish(.windowAppearance_changeCornerRadius, payload: WindowAppearanceState.cornerRadius)
    }
}
