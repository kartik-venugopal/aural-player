import Cocoa

/*
    Controller for the popup menu that lists the available color schemes and opens the color scheme editor panel.
 */
class FontSchemePopupMenuController: NSObject, NSMenuDelegate {
    
    private lazy var fontSchemesDialog: ModalDialogDelegate = WindowFactory.fontSchemesDialog
    
    // TODO: This will be required when allowing custom fonts.
//    func menuNeedsUpdate(_ menu: NSMenu) {
//    }
    
    @IBAction func applyFontSchemeAction(_ sender: NSMenuItem) {
        
        if let fontScheme = FontSchemes.applyFontScheme(named: sender.title) {
            Messenger.publish(.applyFontScheme, payload: fontScheme)
        }
    }
    
    @IBAction func customizeFontSchemeAction(_ sender: NSMenuItem) {
        _ = fontSchemesDialog.showDialog()
    }
}
