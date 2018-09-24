import Cocoa

class ViewPreferencesViewController: NSViewController, NSMenuDelegate, PreferencesViewProtocol {
    
    @IBOutlet weak var btnStartWithLayout: NSButton!
    @IBOutlet weak var btnRememberLayout: NSButton!
    @IBOutlet weak var layoutMenu: NSPopUpButton!
    
    @IBOutlet weak var btnSnapToWindows: NSButton!
    @IBOutlet weak var lblWindowGap: NSTextField!
    @IBOutlet weak var gapStepper: NSStepper!
    
    @IBOutlet weak var btnSnapToScreen: NSButton!
    
    override var nibName: String? {return "ViewPreferences"}
    
    func getView() -> NSView {
        return self.view
    }
    
    func resetFields(_ preferences: Preferences) {
        
        let viewPrefs = preferences.viewPreferences
     
        if (viewPrefs.layoutOnStartup.option == .specific) {
            btnStartWithLayout.state = 1
        } else {
            btnRememberLayout.state = 1
        }
        
        if let item = layoutMenu.item(withTitle: viewPrefs.layoutOnStartup.layoutName) {
            layoutMenu.select(item)
        } else {
            // Default
            layoutMenu.select(layoutMenu.item(withTitle: WindowLayouts.defaultLayout.name))
        }
        layoutMenu.isEnabled = Bool(btnStartWithLayout.state)
        
        btnSnapToWindows.state = viewPrefs.snapToWindows ? 1 : 0
        gapStepper.floatValue = viewPrefs.windowGap
        lblWindowGap.stringValue = ValueFormatter.formatPixels(gapStepper.floatValue)
        [lblWindowGap, gapStepper].forEach({$0.isEnabled = Bool(btnSnapToWindows.state)})
        
        btnSnapToScreen.state = viewPrefs.snapToScreen ? 1 : 0
    }
    
    @IBAction func layoutOnStartupAction(_ sender: Any) {
        layoutMenu.isEnabled = Bool(btnStartWithLayout.state)
    }
    
    @IBAction func snapToWindowsAction(_ sender: Any) {
        [lblWindowGap, gapStepper].forEach({$0.isEnabled = Bool(btnSnapToWindows.state)})
    }
    
    @IBAction func gapStepperAction(_ sender: Any) {
        lblWindowGap.stringValue = ValueFormatter.formatPixels(gapStepper.floatValue)
    }

    func save(_ preferences: Preferences) throws {
        
        let viewPrefs = preferences.viewPreferences
        
        viewPrefs.layoutOnStartup.option = btnStartWithLayout.state == 1 ? .specific : .rememberFromLastAppLaunch
        viewPrefs.layoutOnStartup.layoutName = layoutMenu.selectedItem!.title
        
        viewPrefs.snapToWindows = Bool(btnSnapToWindows.state)
        
        let oldWindowGap = viewPrefs.windowGap
        viewPrefs.windowGap = gapStepper.floatValue
        
        // Check if window gap was changed
        if (viewPrefs.windowGap != oldWindowGap) {
            
            // Recompute system-defined layouts based on new gap between windows
            WindowLayouts.recomputeSystemDefinedLayouts()
        }
        
        viewPrefs.snapToScreen = Bool(btnSnapToScreen.state)
    }
    
    // MARK: Menu delegate
    
    // When the menu is about to open, set the menu item states according to the current window/view state
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        // Recreate the custom layout items
        let itemCount = layoutMenu.itemArray.count
        
        let customLayoutCount = itemCount - 9  // 1 separator, 8 presets
        
        if customLayoutCount > 0 {
            
            // Need to traverse in descending order because items are going to be removed
            for index in (0..<customLayoutCount).reversed() {
                layoutMenu.removeItem(at: index)
            }
        }
        
        // Layout popup button menu
        WindowLayouts.userDefinedLayouts.forEach({
            self.layoutMenu.insertItem(withTitle: $0.name, at: 0)
        })
    }
}
