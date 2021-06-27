//
//  ControlBarPlayerWindowController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class ControlBarPlayerWindowController: NSWindowController, NotificationSubscriber, Destroyable {
    
    @IBOutlet weak var rootContainerBox: NSBox!
    @IBOutlet weak var viewController: ControlBarPlayerViewController!
    
    private let fontSchemesManager: FontSchemesManager = ObjectGraph.fontSchemesManager
    private let colorSchemesManager: ColorSchemesManager = ObjectGraph.colorSchemesManager
    
    override var windowNibName: String? {"ControlBarPlayer"}
    
    override func windowDidLoad() {
        
        window?.isMovableByWindowBackground = true
        window?.delegate = viewController
        
        rootContainerBox.fillColor = colorSchemesManager.systemScheme.general.backgroundColor
        rootContainerBox.cornerRadius = 4
    }
    
    func destroy() {
        
        close()
        viewController.destroy()
        Messenger.unsubscribeAll(for: self)
    }
}
