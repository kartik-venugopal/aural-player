import Cocoa

/*
    Controller for the popup menu that lists the available themes and opens the theme editor panel.
 */
class ThemePopupMenuController: GenericPresetPopupMenuController {
    
    private lazy var creationDialogController: CreateThemeDialogController = CreateThemeDialogController.instance
    private lazy var managerWindowController: PresetsManagerWindowController = PresetsManagerWindowController.instance
    
    private lazy var themesManager: ThemesManager = ObjectGraph.themesManager
    private lazy var fontSchemesManager: FontSchemesManager = ObjectGraph.fontSchemesManager
    private lazy var colorSchemesManager: ColorSchemesManager = ObjectGraph.colorSchemesManager
    
    override var descriptionOfPreset: String {"theme"}
    override var descriptionOfPreset_plural: String {"themes"}
    
    override var userDefinedPresets: [MappedPreset] {themesManager.userDefinedPresets}
    override var numberOfUserDefinedPresets: Int {themesManager.numberOfUserDefinedPresets}
    
    override func presetExists(named name: String) -> Bool {
        themesManager.presetExists(named: name)
    }
    
    // Receives a new theme name and saves the new theme.
    override func addPreset(named name: String) {
        
        // Copy the current system scheme into the new scheme, and name it with the user's given scheme name
        let fontScheme: FontScheme = FontScheme("Font scheme for theme '\(name)'", false, fontSchemesManager.systemScheme)
        let colorScheme: ColorScheme = ColorScheme("Color scheme for theme '\(name)'", false, colorSchemesManager.systemScheme)
        let windowAppearance: WindowAppearance = WindowAppearance(cornerRadius: WindowAppearanceState.cornerRadius)
        
        themesManager.addPreset(Theme(name: name, fontScheme: fontScheme, colorScheme: colorScheme, windowAppearance: windowAppearance, userDefined: true))
    }
    
    override func applyPreset(named name: String) {
        
        if themesManager.applyTheme(named: name) {
            Messenger.publish(.applyTheme)
        }
    }
    
    @IBAction func createThemeAction(_ sender: NSMenuItem) {
        _ = creationDialogController.showDialog()
    }
    
    @IBAction func manageThemesAction(_ sender: NSMenuItem) {
        managerWindowController.showThemesManager()
    }
    
    deinit {
        CreateThemeDialogController.destroy()
    }
}
