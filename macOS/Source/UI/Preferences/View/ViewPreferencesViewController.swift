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
    
    @IBOutlet weak var btnSnapToWindows: CheckBox!
    @IBOutlet weak var lblWindowGap: NSTextField!
    @IBOutlet weak var gapStepper: NSStepper!
    
    @IBOutlet weak var btnSnapToScreen: CheckBox!
    
    override var nibName: NSNib.Name? {"ViewPreferences"}
    
    var preferencesView: NSView {self.view}
    
    func resetFields() {
        
        let viewPrefs = preferences.viewPreferences
        
        btnSnapToWindows.onIf(viewPrefs.snapToWindows.value)
        gapStepper.floatValue = viewPrefs.windowGap.value
        lblWindowGap.stringValue = ValueFormatter.formatPixels(gapStepper.floatValue)
        [lblWindowGap, gapStepper].forEach {$0!.enableIf(btnSnapToWindows.isOn)}
        
        btnSnapToScreen.onIf(viewPrefs.snapToScreen.value)
    }
    
    @IBAction func snapToWindowsAction(_ sender: Any) {
        [lblWindowGap, gapStepper].forEach {$0!.enableIf(btnSnapToWindows.isOn)}
    }
    
    @IBAction func gapStepperAction(_ sender: Any) {
        lblWindowGap.stringValue = ValueFormatter.formatPixels(gapStepper.floatValue)
    }

    func save() throws {
        
        let viewPrefs = preferences.viewPreferences
        
        viewPrefs.snapToWindows.value = btnSnapToWindows.isOn

        let oldWindowGap = viewPrefs.windowGap.value
        viewPrefs.windowGap.value = gapStepper.floatValue

        // Check if window gap was changed
        if gapStepper.floatValue != oldWindowGap {

            // Recompute system-defined layouts based on new gap between windows
            windowLayoutsManager.recomputeSystemDefinedLayouts()
        }
        
        viewPrefs.snapToScreen.value = btnSnapToScreen.isOn
    }
}
