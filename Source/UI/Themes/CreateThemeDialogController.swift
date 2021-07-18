//
//  CreateThemeDialogController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class CreateThemeDialogController: NSWindowController, StringInputReceiver, ModalDialogDelegate, Destroyable {
    
    private static var _instance: CreateThemeDialogController?
    static var instance: CreateThemeDialogController {
        
        if _instance == nil {
            _instance = CreateThemeDialogController()
        }
        
        return _instance!
    }
    
    static func destroy() {
        
        _instance?.destroy()
        _instance = nil
    }
    
    override var windowNibName: NSNib.Name? {"CreateTheme"}
    
    @IBOutlet weak var txtName: NSTextField!
    @IBOutlet weak var errorBox: NSBox!
    @IBOutlet weak var lblError: NSTextField!
    
    @IBOutlet weak var btnFontSchemesMenu: NSPopUpButton!
    @IBOutlet weak var fontSchemesMenu: NSMenu!
    
    @IBOutlet weak var btnColorSchemesMenu: NSPopUpButton!
    @IBOutlet weak var colorSchemesMenu: NSMenu!
    
    @IBOutlet weak var windowCornerRadiusStepper: NSStepper!
    @IBOutlet weak var lblWindowCornerRadius: NSTextField!
    
    private lazy var themesManager: ThemesManager = objectGraph.themesManager
    
    private lazy var fontSchemesManager: FontSchemesManager = objectGraph.fontSchemesManager
    private lazy var colorSchemesManager: ColorSchemesManager = objectGraph.colorSchemesManager
    
    var isModal: Bool {
        return self.window?.isVisible ?? false
    }
    
    override func windowDidLoad() {

        self.window?.isMovableByWindowBackground = true
        
        for theMenu in [fontSchemesMenu, colorSchemesMenu] as! [NSMenu] {
        
            theMenu.insertItem(NSMenuItem.createDescriptor(title: "Built-in schemes"), at: 0)
            theMenu.insertItem(NSMenuItem.separator(), at: 0)
            
            theMenu.insertItem(NSMenuItem.separator(), at: 0)
            theMenu.insertItem(NSMenuItem.createDescriptor(title: "Custom schemes"), at: 0)
            theMenu.insertItem(NSMenuItem.separator(), at: 0)
        }
        
        lblError?.font = Fonts.stringInputPopoverErrorFont
    }
    
    func showDialog() -> ModalDialogResponse {
        
        forceLoadingOfWindow()
        
        txtName.stringValue = "My New Theme"
        txtName.selectText(nil)
        
        initFontSchemesMenu()
        initColorSchemesMenu()
        
        windowCornerRadiusStepper.integerValue = WindowAppearanceState.defaultCornerRadius.roundedInt
        lblWindowCornerRadius.stringValue = "\(windowCornerRadiusStepper.integerValue) px"
        
        errorBox.hide()
        
        theWindow.showCenteredOnScreen()
        
        return .ok
    }
    
    private func initFontSchemesMenu() {
        
        // Remove all user-defined scheme items (i.e. all items before the first separator)
        while let item = fontSchemesMenu.item(at: 3), !item.isSeparatorItem {
            fontSchemesMenu.removeItem(at: 3)
        }
        
        // Recreate the user-defined scheme items
        fontSchemesManager.userDefinedPresets.forEach {

            let item: NSMenuItem = NSMenuItem(title: $0.name)
            item.indentationLevel = 1
            fontSchemesMenu.insertItem(item, at: 3)
        }
        
        let numberOfUserDefinedSchemes: Int = fontSchemesManager.numberOfUserDefinedPresets
        
        for index in 0...2 {
            fontSchemesMenu.item(at: index)?.showIf(numberOfUserDefinedSchemes > 0)
        }
        
        btnFontSchemesMenu.select(fontSchemesMenu.item(withTitle: FontSchemePreset.standard.name))
    }
    
    private func initColorSchemesMenu() {
        
        // Remove all user-defined scheme items (i.e. all items before the first separator)
        while let item = colorSchemesMenu.item(at: 3), !item.isSeparatorItem {
            colorSchemesMenu.removeItem(at: 3)
        }
        
        // Recreate the user-defined scheme items
        colorSchemesManager.userDefinedPresets.forEach {
            
            let item: NSMenuItem = NSMenuItem(title: $0.name)
            item.indentationLevel = 1
            colorSchemesMenu.insertItem(item, at: 3)
        }
        
        for index in 0...2 {
            colorSchemesMenu.item(at: index)?.showIf(colorSchemesManager.numberOfUserDefinedPresets > 0)
        }
        
        btnColorSchemesMenu.select(colorSchemesMenu.item(withTitle: ColorSchemePreset.blackAttack.name))
    }
    
    @IBAction func cornerRadiusStepperAction(_ sender: NSStepper) {
        lblWindowCornerRadius.stringValue = "\(windowCornerRadiusStepper.integerValue) px"
    }
    
    @IBAction func okAction(_ sender: Any) {
        
        // Validate input by calling back to the client
        let validation = validate(txtName.stringValue)
        
        if !validation.valid {
            
            lblError.stringValue = validation.errorMsg ?? ""
            errorBox.show()
            
        } else {
            
            acceptInput(txtName.stringValue)
            theWindow.close()
        }
    }
    
    // Dismisses the panel when the user is done making changes
    @IBAction func cancelAction(_ sender: Any) {
        theWindow.close()
    }
    
    // MARK - StringInputReceiver functions (to receive the name of a new user-defined color scheme)
    
    var inputPrompt: String {
        return "Enter a new theme name:"
    }
    
    var defaultValue: String? {
        return "<New theme>"
    }
    
    func validate(_ string: String) -> (valid: Bool, errorMsg: String?) {
        
        if themesManager.presetExists(named: string) {
            return (false, "Theme with this name already exists !")
        } else if string.trim().isEmpty {
            return (false, "Name must have at least 1 character.")
        } else {
            return (true, nil)
        }
    }
    
    // Receives a new color scheme name and saves the new scheme
    func acceptInput(_ string: String) {
        
        guard let fontSchemeName = btnFontSchemesMenu.titleOfSelectedItem,
              let fontScheme = fontSchemesManager.preset(named: fontSchemeName),
              let colorSchemeName = btnColorSchemesMenu.titleOfSelectedItem,
              let colorScheme = colorSchemesManager.preset(named: colorSchemeName) else {
            
            NSLog("Don't have all the required information ... can't create theme with name '\(string)'.")
            return
        }
        
        // Copy the current system scheme into the new scheme, and name it with the user's given scheme name
        let themeFontScheme: FontScheme = FontScheme("Font scheme for theme '\(string)'", false, fontScheme)
        let themeColorScheme: ColorScheme = ColorScheme("Color scheme for theme '\(string)'", false, colorScheme)
        
        let windowAppearance: WindowAppearance = WindowAppearance(cornerRadius: CGFloat(windowCornerRadiusStepper.integerValue))
        
        themesManager.addPreset(Theme(name: string, fontScheme: themeFontScheme, colorScheme: themeColorScheme,
                                      windowAppearance: windowAppearance, userDefined: true))
    }
}
