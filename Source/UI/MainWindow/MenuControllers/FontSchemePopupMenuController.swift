import Cocoa

/*
    Controller for the popup menu that lists the available font schemes and opens the font scheme editor panel.
 */
class FontSchemePopupMenuController: GenericPresetPopupMenuController {
    
    private lazy var customizationDialogController: FontSchemesWindowController = FontSchemesWindowController.instance
    private lazy var managerWindowController: PresetsManagerWindowController = PresetsManagerWindowController.instance
    
    private lazy var fontSchemesManager: FontSchemesManager = ObjectGraph.fontSchemesManager
    
    override var descriptionOfPreset: String {"font scheme"}
    override var descriptionOfPreset_plural: String {"font schemes"}
    
    override var userDefinedPresets: [MappedPreset] {fontSchemesManager.userDefinedPresets}
    override var numberOfUserDefinedPresets: Int {fontSchemesManager.numberOfUserDefinedPresets}
    
    override func presetExists(named name: String) -> Bool {
        fontSchemesManager.presetExists(named: name)
    }
    
    // Receives a new font scheme name and saves the new scheme
    override func addPreset(named name: String) {
        
        // Copy the current system scheme into the new scheme, and name it with the user's given scheme name
        let newScheme: FontScheme = FontScheme(name, false, fontSchemesManager.systemScheme)
        fontSchemesManager.addPreset(newScheme)
    }
    
    override func applyPreset(named name: String) {
        
        if let fontScheme = fontSchemesManager.applyScheme(named: name) {
            Messenger.publish(.applyFontScheme, payload: fontScheme)
        }
    }
    
    @IBAction func customizeFontSchemeAction(_ sender: NSMenuItem) {
        _ = customizationDialogController.showDialog()
    }
    
    @IBAction func manageSchemesAction(_ sender: NSMenuItem) {
        managerWindowController.showFontSchemesManager()
    }
    
    deinit {
        FontSchemesWindowController.destroy()
    }
}
