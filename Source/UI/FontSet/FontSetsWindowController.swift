import Cocoa

/*
    Controller for the color scheme editor panel that allows the current system color scheme to be edited.
 */
class FontSetsWindowController: NSWindowController, ModalDialogDelegate {
    
    @IBOutlet weak var tabView: AuralTabView!
    
    @IBOutlet weak var btnSave: NSButton!
    
    private lazy var generalView: GeneralFontSetViewController = GeneralFontSetViewController()
    
    override var windowNibName: NSNib.Name? {return "FontSets"}
    
    var isModal: Bool {
        return self.window?.isVisible ?? false
    }
    
    override func windowDidLoad() {

        self.window?.isMovableByWindowBackground = true

        // Add the subviews to the tab group
//        subViews = [generalSchemeView, playerSchemeView, playlistSchemeView, effectsSchemeView]
//        tabView.addViewsForTabs(subViews.map {$0.colorSchemeView})

        tabView.addViewsForTabs([generalView.view, NSView(), NSView(), NSView()])

//        // Register an observer that updates undo/redo button states whenever the history changes.
//        history.changeListener = {
//            self.updateButtonStates()
//        }
//
//        // Set up an observer that responds whenever the clipboard color is changed (so that the UI can be updated accordingly)
//        clipboard.colorChangeCallback = {
//
//            if let color = self.clipboard.color {
//
//                self.clipboardColorViewer.color = color
//                [self.clipboardIcon, self.clipboardColorViewer].forEach({$0?.show()})
//
//            } else {
//
//                [self.clipboardIcon, self.clipboardColorViewer].forEach({$0?.hide()})
//            }
//        }

        // Register self as a modal component
        WindowManager.registerModalComponent(self)
    }
    
    func showDialog() -> ModalDialogResponse {
        
        // Force loading of the window if it hasn't been loaded yet (only once)
        if !self.isWindowLoaded {
            _ = self.window!
        }
        
        // Reset the subviews according to the current system color scheme, and show the first tab
//        subViews.forEach({$0.resetFields(ColorSchemes.systemScheme, history, clipboard)})
        tabView.selectTabViewItem(at: 0)
        
        // Enable/disable function buttons
//        updateButtonStates()
        
        UIUtils.showDialog(self.window!)
        
        return .ok
    }
    
    // Dismisses the panel when the user is done making changes
    @IBAction func doneAction(_ sender: Any) {
        
        // Close the system color chooser panel.
        NSColorPanel.shared.close()
        UIUtils.dismissDialog(self.window!)
    }
    
    func changeFont(_ sender: Any?) {
            
            // the sender is a font manager
            guard let fontManager = sender as? NSFontManager else {
                return
            }
            
            // the newly selected font
            /*
                you can actually pass in any font into the .convert() function and it
                will return the selected font from the panel, lol
            */
            
    //        let newFont = fontManager.convert(NSFont.systemFont(ofSize: 13.0))
        let selFont = fontManager.convert(Fonts.Standard.captionFont_13)
        print("You selected the font:", selFont.displayName, selFont.fontName, selFont.familyName, selFont.pointSize)
    }
}

/*
    Contract for all subviews that alter the color scheme, to facilitate communication between the window controller and subviews.
 */
protocol FontSetsViewProtocol {
    
    // The view containing the color editing UI components
    var fontSetsView: NSView {get}
    
    // Reset all UI controls every time the dialog is shown or a new color scheme is applied.
    // NOTE - the history and clipboard are shared across all views
    func resetFields(_ scheme: ColorScheme)
    
    // If the last change was made to a control in this view, performs an undo operation and returns true. Otherwise, does nothing and returns false.
    func undoChange(_ lastChange: ColorSchemeChange) -> Bool

    // If the last undo was performed on a control in this view, performs a redo operation and returns true. Otherwise, does nothing and returns false.
    func redoChange(_ lastChange: ColorSchemeChange) -> Bool
}
