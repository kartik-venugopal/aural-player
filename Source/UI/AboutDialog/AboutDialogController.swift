//
//  AboutDialogController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class AboutDialogController: NSWindowController, ModalComponentProtocol {
    
    override var windowNibName: NSNib.Name? {"AboutDialog"}
    
    @IBOutlet weak var versionLabel: NSTextField! {
        
        didSet {
            versionLabel.stringValue = NSApp.appVersion
        }
    }
    
    override func showWindow(_ sender: Any?) {
        
        if let mainWindow = appModeManager.mainWindow {
            theWindow.showCentered(relativeTo: mainWindow)
        } else {
            theWindow.showCenteredOnScreen()
        }
    }
    
    var isModal: Bool {self.window?.isVisible ?? false}
}
