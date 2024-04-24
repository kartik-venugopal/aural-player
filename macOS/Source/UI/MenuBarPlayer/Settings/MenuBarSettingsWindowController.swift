//
//  MenuBarSettingsWindowController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class MenuBarSettingsWindowController: NSWindowController {
    
    override var windowNibName: NSNib.Name? {"MenuBarSettings"}
    
    @IBOutlet weak var btnShowPlayQueue: CheckBox!
    
    private lazy var messenger = Messenger(for: self)
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        btnShowPlayQueue.onIf(menuBarPlayerUIState.showPlayQueue)
    }
    
    // Shows/hides the Play Queue view
    @IBAction func showPlayQueueAction(_ sender: NSButton) {
        
        menuBarPlayerUIState.showPlayQueue = sender.isOn
        messenger.publish(.MenuBarPlayer.togglePlayQueue)
    }
    
    @IBAction func changeSeekPositionDisplayTypeAction(_ sender: NSButton) {
        
//        playerUIState.trackTimeDisplayType = sender.displayType
//        setTrackTimeDisplayType(to: playerUIState.trackTimeDisplayType)
    }
    
    @IBAction func switchPresentationModeAction(_ sender: NSPopUpButton) {
        
        if let modeId = sender.selectedItem?.identifier?.rawValue,
        let appMode = AppMode(rawValue: modeId) {
            
            appModeManager.presentMode(appMode)
        }
        
        close()
    }
    
    @IBAction func doneAction(_ sender: NSButton) {
        close()
    }
}

class MenuBarSettingsPopupViewController: NSViewController {
    
    override var nibName: String? {"MenuBarSettings"}
    
//    // Shows the popover
//    func show(relativeTo view: NSView, preferredEdge: NSRectEdge) {
//        
//        if !isShown {
//            popover.show(relativeTo: positioningRect, of: view, preferredEdge: preferredEdge)
//        }
//    }
//    
//    // Closes the popover
//    @objc override func close() {
//        super.close()
//    }
}
