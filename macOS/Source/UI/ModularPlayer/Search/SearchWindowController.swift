//
//  SearchWindowController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class SearchWindowController: NSWindowController {
    
    override var windowNibName: String? {"SearchWindow"}
    
    private lazy var viewController: SearchViewController = .init()
    
    /// Singleton
    static let shared: SearchWindowController = .init()
    
    override func windowDidLoad() {
        
        super.windowDidLoad()

        theWindow.contentView?.addSubview(viewController.view)
        viewController.view.anchorToSuperview()
        
        theWindow.center()
    }
    
    @IBAction func closeAction(sender: NSButton) {
        close()
    }
}
