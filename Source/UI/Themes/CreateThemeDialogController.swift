//
//  CreateThemeDialogController.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class CreateThemeDialogController: SingletonWindowController, StringInputReceiver, ModalDialogDelegate {
    
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
        
        for theMenu in [fontSchemesMenu, colorSchemesMenu].compactMap({$0}) {
        
            theMenu.insertItem(.createDescriptor(title: "Built-in schemes"), at: 0)
            theMenu.insertItem(.separator(), at: 0)
            
            theMenu.insertItem(.separator(), at: 0)
            theMenu.insertItem(.createDescriptor(title: "Custom schemes"), at: 0)
            theMenu.insertItem(.separator(), at: 0)
        }
        
        lblError?.font = .stringInputPopoverErrorFont
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
        
        fontSchemesMenu.recreateMenu(insertingItemsAt: 3, fromItems: fontSchemesManager.userDefinedObjects,
                                     indentationLevel: 1)
        
        let showDescriptors: Bool = fontSchemesManager.numberOfUserDefinedObjects > 0
        
        for index in 0...2 {
            fontSchemesMenu.item(at: index)?.showIf(showDescriptors)
        }
        
        btnFontSchemesMenu.selectItem(withTitle: FontSchemePreset.standard.name)
    }
    
    private func initColorSchemesMenu() {
        
        colorSchemesMenu.recreateMenu(insertingItemsAt: 3, fromItems: colorSchemesManager.userDefinedObjects,
                                      indentationLevel: 1)
        
        let showDescriptors: Bool = colorSchemesManager.numberOfUserDefinedObjects > 0
        
        for index in 0...2 {
            colorSchemesMenu.item(at: index)?.showIf(showDescriptors)
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
        
        if themesManager.objectExists(named: string) {
            return (false, "Theme with this name already exists !")
        } else if string.isEmptyAfterTrimming {
            return (false, "Name must have at least 1 character.")
        } else {
            return (true, nil)
        }
    }
    
    // Receives a new color scheme name and saves the new scheme
    func acceptInput(_ string: String) {
        
        guard let fontSchemeName = btnFontSchemesMenu.titleOfSelectedItem,
              let fontScheme = fontSchemesManager.object(named: fontSchemeName),
              let colorSchemeName = btnColorSchemesMenu.titleOfSelectedItem,
              let colorScheme = colorSchemesManager.object(named: colorSchemeName) else {
            
            NSLog("Don't have all the required information ... can't create theme with name '\(string)'.")
            return
        }
        
        // Copy the current system scheme into the new scheme, and name it with the user's given scheme name
        let themeFontScheme: FontScheme = FontScheme("Font scheme for theme '\(string)'", false, fontScheme)
        let themeColorScheme: ColorScheme = ColorScheme("Color scheme for theme '\(string)'", false, colorScheme)
        
        let windowAppearance: WindowAppearance = WindowAppearance(cornerRadius: CGFloat(windowCornerRadiusStepper.integerValue))
        
        themesManager.addObject(Theme(name: string, fontScheme: themeFontScheme, colorScheme: themeColorScheme,
                                      windowAppearance: windowAppearance, userDefined: true))
    }
}
