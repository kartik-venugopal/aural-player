import Cocoa

class AboutDialogController: NSWindowController {
    
    override var windowNibName: String? {return "AboutDialog"}
    
    @IBOutlet weak var versionLabel: NSTextField! {
        
        didSet {
            versionLabel.stringValue = String(format: "Version %@", AppConstants.appVersion)
        }
    }
}
