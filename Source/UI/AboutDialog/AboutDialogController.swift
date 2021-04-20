import Cocoa

class AboutDialogController: NSWindowController, ModalComponentProtocol {
    
    override var windowNibName: String? {"AboutDialog"}
    
    @IBOutlet weak var versionLabel: NSTextField! {
        
        didSet {
            
            let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
            versionLabel.stringValue = appVersion
        }
    }
    
    override func windowDidLoad() {
        WindowManager.instance.registerModalComponent(self)
    }
    
    var isModal: Bool {self.window?.isVisible ?? false}
}
