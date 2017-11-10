import Cocoa

/*
    Provides actions for the Aural menu
 */
class AuralMenuController: NSObject {
    
    private lazy var preferencesDialog: ModalDialogDelegate = WindowManager.getPreferencesDialog()
    
    private lazy var app: NSApplication = NSApplication.shared()
    
    // Presents the Preferences modal dialog
    @IBAction func preferencesAction(_ sender: Any) {
        preferencesDialog.showDialog()
    }
    
    @IBAction func hideAction(_ sender: AnyObject) {
        app.hide(self)
    }
    
    @IBAction func quitAction(_ sender: AnyObject) {
        app.terminate(self)
    }
}
