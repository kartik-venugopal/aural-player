import Cocoa

/*
    Provides actions for the main app menu (Aural)
 */
class AuralMenuController: NSObject {
    
    private lazy var preferencesDialog: ModalDialogDelegate = WindowFactory.getPreferencesDialog()
    
    private lazy var aboutDialog: AboutDialogController = AboutDialogController()
    
    @IBAction func aboutAction(_ sender: AnyObject) {
        UIUtils.centerDialogWRTMainWindow(aboutDialog.window!)
    }
    
    // Presents the Preferences modal dialog
    @IBAction func preferencesAction(_ sender: Any) {
        _ = preferencesDialog.showDialog()
    }
    
    // Hides the app
    @IBAction func hideAction(_ sender: AnyObject) {
        NSApp.hide(self)
    }
    
    // Quits the app
    @IBAction func quitAction(_ sender: AnyObject) {
        NSApp.terminate(self)
    }
}
