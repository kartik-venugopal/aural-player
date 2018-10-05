import Cocoa

class ViewPreferencesViewController: NSViewController, PreferencesViewProtocol {
    
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
            btnStartWithLayout.state = convertToNSControlStateValue(1)
        } else {
            btnRememberLayout.state = convertToNSControlStateValue(1)
        }
        
        updateLayoutMenu()
        
        if let item = layoutMenu.item(withTitle: viewPrefs.layoutOnStartup.layoutName) {
            layoutMenu.select(item)
        } else {
            // Default
            layoutMenu.select(layoutMenu.item(withTitle: WindowLayouts.defaultLayout.name))
        }
        layoutMenu.isEnabled = Bool(btnStartWithLayout.state.rawValue)
        
        btnSnapToWindows.state = NSControl.StateValue(rawValue: viewPrefs.snapToWindows ? 1 : 0)
        gapStepper.floatValue = viewPrefs.windowGap
        lblWindowGap.stringValue = ValueFormatter.formatPixels(gapStepper.floatValue)
        [lblWindowGap, gapStepper].forEach({$0!.isEnabled = Bool(btnSnapToWindows.state.rawValue)})
        
        btnSnapToScreen.state = NSControl.StateValue(rawValue: viewPrefs.snapToScreen ? 1 : 0)
    }
    
    // Update the layout menu with custom layouts
    private func updateLayoutMenu() {
        
        // Recreate the custom layout items
        let itemCount = layoutMenu.itemArray.count
        
        let customLayoutCount = itemCount - 9  // 1 separator, 8 presets
        
        if customLayoutCount > 0 {
            
            // Need to traverse in descending order because items are going to be removed
            for index in (0..<customLayoutCount).reversed() {
                layoutMenu.removeItem(at: index)
            }
        }
        
        // Reinsert the custom layouts
        WindowLayouts.userDefinedLayouts.forEach({
            self.layoutMenu.insertItem(withTitle: $0.name, at: 0)
        })
    }
    
    @IBAction func layoutOnStartupAction(_ sender: Any) {
        layoutMenu.isEnabled = Bool(btnStartWithLayout.state.rawValue)
    }
    
    @IBAction func snapToWindowsAction(_ sender: Any) {
        [lblWindowGap, gapStepper].forEach({$0!.isEnabled = Bool(btnSnapToWindows.state.rawValue)})
    }
    
    @IBAction func gapStepperAction(_ sender: Any) {
        lblWindowGap.stringValue = ValueFormatter.formatPixels(gapStepper.floatValue)
    }

    func save(_ preferences: Preferences) throws {
        
        let viewPrefs = preferences.viewPreferences
        
        viewPrefs.layoutOnStartup.option = btnStartWithLayout.state.rawValue == 1 ? .specific : .rememberFromLastAppLaunch
        viewPrefs.layoutOnStartup.layoutName = layoutMenu.selectedItem!.title
        
        viewPrefs.snapToWindows = Bool(btnSnapToWindows.state.rawValue)
        
        let oldWindowGap = viewPrefs.windowGap
        viewPrefs.windowGap = gapStepper.floatValue
        
        // Check if window gap was changed
        if (viewPrefs.windowGap != oldWindowGap) {
            
            // Recompute system-defined layouts based on new gap between windows
            WindowLayouts.recomputeSystemDefinedLayouts()
        }
        
        viewPrefs.snapToScreen = Bool(btnSnapToScreen.state.rawValue)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSControlStateValue(_ input: Int) -> NSControl.StateValue {
	return NSControl.StateValue(rawValue: input)
}
