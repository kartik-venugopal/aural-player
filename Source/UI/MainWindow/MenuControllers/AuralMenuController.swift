//
//  AuralMenuController.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Provides actions for the main app menu (Aural)
 */
class AuralMenuController: NSObject {
    
    private lazy var preferencesDialog: PreferencesWindowController = PreferencesWindowController()
    
    private lazy var aboutDialog: AboutDialogController = AboutDialogController()
    
    @IBAction func aboutAction(_ sender: AnyObject) {
        aboutDialog.showWindow(self)
    }
    
    // Presents the Preferences modal dialog
    @IBAction func preferencesAction(_ sender: Any) {
        _ = preferencesDialog.showDialog()
    }
    
    // Hides the app
    @IBAction func hideAction(_ sender: AnyObject) {
        NSApp.hide(self)
    }
    
    // Quits the app
    @IBAction func quitAction(_ sender: AnyObject) {
        NSApp.terminate(self)
    }
    
    deinit {
        preferencesDialog.destroy()
    }
}
