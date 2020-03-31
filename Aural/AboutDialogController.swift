import Cocoa

class AboutDialogController: NSWindowController, NSWindowDelegate {
    
    override var windowNibName: String? {return "AboutDialog"}
    
    @IBOutlet weak var versionLabel: NSTextField! {
        
        didSet {
            
            let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
            versionLabel.stringValue = appVersion
        }
    }
    
    func windowWillClose(_ notification: Notification) {
        WindowState.showingPopover = false
    }
}
