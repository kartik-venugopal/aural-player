//
// AppInitializerDialogController.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import AppKit

class AppInitializerDialogController: NSWindowController {
    
    override var windowNibName: NSNib.Name? {"AppInitializer"}
    
    @IBOutlet weak var lblStatus: NSTextField!
    @IBOutlet weak var progressBar: NSProgressIndicator!
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        window?.isMovableByWindowBackground = true
        
//        if let frame = appModeManager.predictedMainWindowFrame {
//            
//            print("Frame: \(frame)")
//            window?.setFrame(frame, display: true)
//        } else {
            window?.center()
//        }
        
        if let contentView = window?.contentView {
            
            contentView.wantsLayer = true
            contentView.layer?.backgroundColor = systemColorScheme.backgroundColor.cgColor
            contentView.layer?.cornerRadius = 4
        }
        
        progressBar.animate()
    }
}
