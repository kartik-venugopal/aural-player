//
//  ViewPreferencesViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class ViewPreferencesViewController: NSViewController, PreferencesViewProtocol {
    
    @IBOutlet weak var btnStartWithAppMode: NSButton!
    @IBOutlet weak var btnRememberAppMode: NSButton!
    @IBOutlet weak var appModeMenu: NSPopUpButton!
    
    @IBOutlet weak var windowedAppModeMenuItem: NSMenuItem!
    @IBOutlet weak var menuBarAppModeMenuItem: NSMenuItem!
    @IBOutlet weak var widgetAppModeMenuItem: NSMenuItem!
    
    @IBOutlet weak var btnStartWithLayout: NSButton!
    @IBOutlet weak var btnRememberLayout: NSButton!
    @IBOutlet weak var layoutMenu: NSPopUpButton!
    
    @IBOutlet weak var btnSnapToWindows: NSButton!
    @IBOutlet weak var lblWindowGap: NSTextField!
    @IBOutlet weak var gapStepper: NSStepper!
    
    @IBOutlet weak var btnSnapToScreen: NSButton!
    
    override var nibName: String? {"ViewPreferences"}
    
    var preferencesView: NSView {self.view}
    
    override func viewDidLoad() {
        
        windowedAppModeMenuItem.representedObject = AppMode.modular
        menuBarAppModeMenuItem.representedObject = AppMode.menuBar
        widgetAppModeMenuItem.representedObject = AppMode.widget
    }
    
    func resetFields() {
        
//        let viewPrefs = preferences.viewPreferences
//        
//        if viewPrefs.appModeOnStartup.option == .specific {
//            btnStartWithAppMode.on()
//        } else {
//            btnRememberAppMode.on()
//        }
//        
//        switch viewPrefs.appModeOnStartup.modeName {
//        
//        case AppMode.modular.rawValue:
//            
//            appModeMenu.select(windowedAppModeMenuItem)
//            
//        case AppMode.menuBar.rawValue:
//            
//            appModeMenu.select(menuBarAppModeMenuItem)
//            
//        case AppMode.widget.rawValue:
//            
//            appModeMenu.select(widgetAppModeMenuItem)
//            
//        default:
//            
//            appModeMenu.select(windowedAppModeMenuItem)
//        }
//        
//        appModeMenu.enableIf(btnStartWithAppMode.isOn)
//     
//        if viewPrefs.layoutOnStartup.option == .specific {
//            btnStartWithLayout.on()
//        } else {
//            btnRememberLayout.on()
//        }
//        
//        updateLayoutMenu()
//        
//        if let layoutName = viewPrefs.layoutOnStartup.layoutName, let item = layoutMenu.item(withTitle: layoutName) {
//            layoutMenu.select(item)
//        } else {
//            // Default
//            layoutMenu.select(layoutMenu.item(withTitle: windowLayoutsManager.defaultLayout.name))
//        }
//        layoutMenu.enableIf(btnStartWithLayout.isOn)
//        
//        btnSnapToWindows.onIf(viewPrefs.snapToWindows)
//        gapStepper.floatValue = viewPrefs.windowGap
//        lblWindowGap.stringValue = ValueFormatter.formatPixels(gapStepper.floatValue)
//        [lblWindowGap, gapStepper].forEach {$0!.enableIf(btnSnapToWindows.isOn)}
//        
//        btnSnapToScreen.onIf(viewPrefs.snapToScreen)
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
        windowLayoutsManager.userDefinedObjects.forEach {
            self.layoutMenu.insertItem(withTitle: $0.name, at: 0)
        }
    }
    
    @IBAction func appModeOnStartupAction(_ sender: Any) {
        appModeMenu.enableIf(btnStartWithAppMode.isOn)
    }
    
    @IBAction func layoutOnStartupAction(_ sender: Any) {
        layoutMenu.enableIf(btnStartWithLayout.isOn)
    }
    
    @IBAction func snapToWindowsAction(_ sender: Any) {
        [lblWindowGap, gapStepper].forEach {$0!.enableIf(btnSnapToWindows.isOn)}
    }
    
    @IBAction func gapStepperAction(_ sender: Any) {
        lblWindowGap.stringValue = ValueFormatter.formatPixels(gapStepper.floatValue)
    }

    func save() throws {
        
//        let viewPrefs = preferences.viewPreferences
//        
//        viewPrefs.appModeOnStartup.option = btnStartWithAppMode.isOn ? .specific : .rememberFromLastAppLaunch
//        viewPrefs.appModeOnStartup.modeName = (appModeMenu.selectedItem?.representedObject as? AppMode)?.rawValue ?? AppMode.defaultMode.rawValue
//        
//        viewPrefs.layoutOnStartup.option = btnStartWithLayout.isOn ? .specific : .rememberFromLastAppLaunch
//        viewPrefs.layoutOnStartup.layoutName = layoutMenu.selectedItem!.title
//        
//        viewPrefs.snapToWindows = btnSnapToWindows.isOn
//        
//        let oldWindowGap = viewPrefs.windowGap
//        viewPrefs.windowGap = gapStepper.floatValue
//        
//        // Check if window gap was changed
//        if viewPrefs.windowGap != oldWindowGap {
//            
//            // Recompute system-defined layouts based on new gap between windows
//            windowLayoutsManager.recomputeSystemDefinedLayouts()
//        }
//        
//        viewPrefs.snapToScreen = btnSnapToScreen.isOn
    }
}
