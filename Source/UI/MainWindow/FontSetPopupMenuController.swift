import Cocoa

/*
    Controller for the popup menu that lists the available color schemes and opens the color scheme editor panel.
 */
class FontSetPopupMenuController: NSObject, NSMenuDelegate {
    
    private lazy var fontSetsDialog: ModalDialogDelegate = WindowFactory.fontSetsDialog
    
    // TODO: This will be required when allowing custom fonts.
//    func menuNeedsUpdate(_ menu: NSMenu) {
//    }
    
    @IBAction func applyFontSetAction(_ sender: NSMenuItem) {
        
        if let fontSet = FontSets.applyFontSet(named: sender.title) {
            Messenger.publish(.applyFontSet, payload: fontSet)
        }
    }
    
    @IBAction func customizeFontSetAction(_ sender: NSMenuItem) {
        _ = fontSetsDialog.showDialog()
    }
}
