//
//  HelpMenuController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Provides actions for the Help menu
 */
class HelpMenuController: NSObject {
    
//    private lazy var workspace: NSWorkspace = NSWorkspace.shared
    
    // Opens the online (HTML) user guide
    @IBAction func onlineUserGuideAction(_ sender: Any) {
//        workspace.open(AppConstants.onlineUserGuideURL)
    }
    
    // Opens the bundled (PDF) user guide
    @IBAction func pdfUserGuideAction(_ sender: Any) {
//        workspace.openFile(AppConstants.pdfUserGuidePath)
    }
}
