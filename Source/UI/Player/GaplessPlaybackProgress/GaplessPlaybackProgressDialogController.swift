//
// GaplessPlaybackProgressDialogController.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import AppKit

class GaplessPlaybackProgressDialogController: NSWindowController {
    
    override var windowNibName: NSNib.Name? {"GaplessPlaybackProgress"}
    
    @IBOutlet weak var activitySpinner: NSProgressIndicator!
    @IBOutlet weak var imgStatus: NSImageView!
    
    @IBOutlet weak var lblStatus: NSTextField!
    @IBOutlet weak var lblDetail: NSTextField!
    
    @IBOutlet weak var btnOK: NSButton!
    
    private lazy var messenger = Messenger(for: self)
    
    override func windowWillLoad() {
        
        super.windowWillLoad()
     
//        messenger.subscribeAsync(to: .PlayQueue.gaplessPlaybackAnalysisCompleted,
//                                 handler: gaplessPlaybackAnalysisCompleted(notif:))
    }
    
    override func showWindow(_ sender: Any?) {
        
        activitySpinner.animate()
        imgStatus.hide()
        lblStatus.stringValue = "Analyzing \(playQueue.size) tracks ..."
        lblDetail.hide()
        btnOK.hide()
     
        if let mainWindow = appModeManager.mainWindow {
            mainWindow.beginSheet(theWindow)
        }
        
//        super.showWindow(sender)
    }
    
//    func gaplessPlaybackAnalysisCompleted(notif: GaplessPlaybackAnalysisNotification) {
//        
//        activitySpinner.dismiss()
//        
//        if notif.success {
//            
//            imgStatus.image = .imgCheck
//            imgStatus.contentTintColor = .green
//            
//            window?.close()
//            
//        } else if let errorMsg = notif.errorMsg {
//            
//            imgStatus.image = .imgError
//            imgStatus.contentTintColor = .red
//            
//            lblStatus.stringValue = "Gapless playback is not possible!"
//            lblDetail.stringValue = errorMsg
//            
//            btnOK.show()
//        }
//    }
    
    @IBAction func okAction(_ sender: NSButton) {
        window?.close()
    }
    
    override func destroy() {
        
        super.destroy()
        messenger.unsubscribeFromAll()
    }
}
