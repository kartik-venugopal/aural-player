import Cocoa

class WindowCornerRadiusMenuItemView: NSView {
    
    @IBOutlet weak var cornerRadiusStepper: NSStepper!
    @IBOutlet weak var lblCornerRadius: NSTextField!
    
    override func awakeFromNib() {
        
        cornerRadiusStepper.integerValue = roundedInt(WindowAppearance.cornerRadius)
        lblCornerRadius.stringValue = "\(cornerRadiusStepper.integerValue) px"
    }
    
    @IBAction func cornerRadiusStepperAction(_ sender: NSStepper) {
        
        WindowAppearance.cornerRadius = CGFloat(cornerRadiusStepper.integerValue)
        lblCornerRadius.stringValue = "\(cornerRadiusStepper.integerValue) px"
        
        Messenger.publish(.windowAppearance_changeCornerRadius, payload: WindowAppearance.cornerRadius)
    }
}
