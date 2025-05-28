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
        
        if let contentView = window?.contentView {
            
            contentView.wantsLayer = true
            contentView.layer?.backgroundColor = systemColorScheme.backgroundColor.cgColor
            contentView.layer?.cornerRadius = 4
        }
        
        progressBar.animate()
        
        // TODO: Factor out the window positioning logic (also to be reused by Unified / Compact / Widget modes)
        
        guard let uiState = appPersistentState.ui else {return}
        guard let appMode = uiState.appMode else {return}
        
        switch appMode {
            
        case .modular:
            
            guard let sysLayoutState = uiState.modularPlayer?.windowLayout?.systemLayout,
                  let mainWindow = sysLayoutState.mainWindow,
                  let offset = mainWindow.screenOffset else {return}
            
            guard let screen = NSScreen.main, let size = mainWindow.size else {return}
            
            let origin = screen.visibleFrame.origin.translating(offset.width, offset.height)
            centerWRT(otherFrame: NSMakeRect(origin.x, origin.y, size.width, size.height))
            
            return
            
        case .unified:
            
            guard let unifiedPlayer = uiState.unifiedPlayer,
                  let windowFrame = unifiedPlayer.windowFrame else {return}
            
            centerWRT(otherFrame: windowFrame)
            
        case .compact:
            
            guard let compactPlayer = uiState.compactPlayer,
                  let windowLocation = compactPlayer.windowLocation else {return}
            
            centerWRT(otherFrame: NSMakeRect(windowLocation.x, windowLocation.y, 300, 430))
            
        default:
            return
        }
        
//        window?.center()
    }
    
    private func centerWRT(otherFrame: NSRect) {
        
        let width = otherFrame.width
        let height = otherFrame.height
        
        let dw = (width - theWindow.width) / 2
        let dh = (height - theWindow.height) / 2
        
        let origin = otherFrame.origin.translating(dw, dh)
        
        var frame = theWindow.frame
        frame.origin = origin
        theWindow.setFrame(frame, display: true)
    }
    
    func stepChanged(to newStep: AppInitializationStep) {
        lblStatus.stringValue = "\(newStep.description) ..."
    }
}
