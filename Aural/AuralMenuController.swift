import Cocoa

/*
    Provides actions for the Aural menu
 */
class AuralMenuController: NSObject {
    
    private lazy var preferencesDialog: ModalDialogDelegate = WindowFactory.getPreferencesDialog()
    
    // Presents the Preferences modal dialog
    @IBAction func preferencesAction(_ sender: Any) {
        preferencesDialog.showDialog()
    }
}
