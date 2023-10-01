//
//  AboutDialogController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class AboutDialogController: NSWindowController, ModalComponentProtocol {
    
    override var windowNibName: String? {"AboutDialog"}
    
    private lazy var windowLayoutsManager: WindowLayoutsManager = objectGraph.windowLayoutsManager
    
    @IBOutlet weak var versionLabel: NSTextField! {
        
        didSet {
            versionLabel.stringValue = NSApp.appVersion
        }
    }
    
    override func showWindow(_ sender: Any?) {
        theWindow.showCentered(relativeTo: windowLayoutsManager.mainWindow)
    }
    
    var isModal: Bool {self.window?.isVisible ?? false}
}
