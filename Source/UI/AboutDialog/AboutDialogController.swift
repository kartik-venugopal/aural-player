//
//  AboutDialogController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class AboutDialogController: NSWindowController, ModalComponentProtocol {
    
    override var windowNibName: String? {"AboutDialog"}
    
    @IBOutlet weak var versionLabel: NSTextField! {
        
        didSet {
            versionLabel.stringValue = NSApp.appVersion
        }
    }
    
    override func showWindow(_ sender: Any?) {
        window?.showCentered(relativeTo: WindowManager.instance.mainWindow)
    }
    
    override func windowDidLoad() {
        WindowManager.instance.registerModalComponent(self)
    }
    
    var isModal: Bool {self.window?.isVisible ?? false}
}
