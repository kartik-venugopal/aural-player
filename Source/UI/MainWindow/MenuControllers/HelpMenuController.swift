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
    
    private lazy var workspace: NSWorkspace = NSWorkspace.shared
    
    private static let supportURL: URL = URL(string: "https://github.com/maculateConception/aural-player/wiki")!
    
    // Opens the online (Wiki) support documentation
    @IBAction func onlineSupportAction(_ sender: Any) {
        workspace.open(Self.supportURL)
    }
}
