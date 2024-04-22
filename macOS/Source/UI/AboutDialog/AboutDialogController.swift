//
//  AboutDialogController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
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
        
        switch appModeManager.currentMode {
            
        case .modular:
            theWindow.showCentered(relativeTo: windowLayoutsManager.mainWindow)
            
        case .unified:
            
            if let window = NSApp.windows.first(where: {$0.identifier?.rawValue == "unifiedPlayer"}) {
                theWindow.showCentered(relativeTo: window)
            }
            
        case .compact:
            
            if let window = NSApp.windows.first(where: {$0.identifier?.rawValue == "compactPlayer"}) {
                theWindow.showCentered(relativeTo: window)
            }
            
        default:
            return
        }
    }
    
    var isModal: Bool {self.window?.isVisible ?? false}
}
