//
//  LibraryHomeSetupViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class LibraryHomeSetupViewController: NSViewController {
    
    override var nibName: String? {"LibraryHomeSetup"}
    
    @IBOutlet weak var lblPath: NSTextField!
    lazy var openFolderDialog = DialogsAndAlerts.openFolderDialog
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        lblPath.stringValue = appSetup.librarySourceFolder.path
        openFolderDialog.message = "Choose the folder containing your music collection."
    }
    
    @IBAction func browseAction(_ sender: Any) {
        
        guard openFolderDialog.runModal() == .OK, let folder = openFolderDialog.url else {return}
        
        lblPath.stringValue = folder.path
        
        appSetup.librarySourceFolder = folder
        print("Set library home folder to: \(appSetup.librarySourceFolder.path)")
    }
}
