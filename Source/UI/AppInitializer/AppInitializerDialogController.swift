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
    
    private lazy var messenger = Messenger(for: self)
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        window?.isMovableByWindowBackground = true
        
        if let contentView = window?.contentView {
            
            contentView.wantsLayer = true
            contentView.layer?.backgroundColor = systemColorScheme.backgroundColor.cgColor
            contentView.layer?.cornerRadius = 4
        }
        
        progressBar.animate()
        
        messenger.subscribeAsync(to: .AppInitialization.stepChanged, handler: stepChanged(to:))
        
        // TODO: Factor out the window positioning logic (also to be reused by Unified / Compact / Widget modes)
        
        if let sysLayoutState = appPersistentState.ui?.modularPlayer?.windowLayout?.systemLayout,
           let mainWindow = sysLayoutState.mainWindow,
           let offset = mainWindow.screenOffset {
            
            if let screen = NSScreen.main, let width = mainWindow.size?.width, let height = mainWindow.size?.height {
                
                let dw = (width - theWindow.width) / 2
                let dh = (height - theWindow.height) / 2
                let origin = screen.visibleFrame.origin.translating(offset.width + dw, offset.height + dh)
                
                var frame = theWindow.frame
                frame.origin = origin
                theWindow.setFrame(frame, display: true)
                return
            }
        }
        
        window?.center()
    }
    
    private func stepChanged(to newStep: AppInitializationStep) {
        lblStatus.stringValue = "\(newStep.description) ..."
    }
}
