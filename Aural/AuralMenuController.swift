import Cocoa

/*
    Provides actions for the main app menu (Aural)
 */
class AuralMenuController: NSObject {
    
    private lazy var preferencesDialog: ModalDialogDelegate = WindowManager.getPreferencesDialog()
    
    private lazy var app: NSApplication = NSApplication.shared()
    
    // Presents the Preferences modal dialog
    @IBAction func preferencesAction(_ sender: Any) {
        preferencesDialog.showDialog()
    }
    
    // Hides the app
    @IBAction func hideAction(_ sender: AnyObject) {
        app.hide(self)
    }
    
    // Quits the app
    @IBAction func quitAction(_ sender: AnyObject) {
        app.terminate(self)
    }
}
