//
//  LibraryBuildProgressViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class LibraryBuildProgressViewController: NSViewController {
    
    override var nibName: String? {"LibraryBuildProgress"}
}

class LibraryBuildProgressWindowController: NSWindowController {
    
//    override var nibName: String? {"LibraryBuildProgress"}
    override var windowNibName: NSNib.Name? {"LibraryBuildProgress"}
    
    @IBOutlet weak var buildProgressSpinner: ProgressArc!
    
    // TODO: Weak self
    private lazy var buildProgressUpdateTask: RepeatingTaskExecutor = .init(intervalMillis: 500, task: updateBuildProgress, queue: .main)
    
    private lazy var messenger: Messenger = .init(for: self)

    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        messenger.subscribeAsync(to: .Library.startedAddingTracks, handler: startedAddingTracks)
        messenger.subscribeAsync(to: .Library.doneAddingTracks, handler: doneAddingTracks)
    }
    
    // MARK: Message handling -----------------------------------------------------------
    
    private func updateBuildProgress() {
        buildProgressSpinner.percentage = libraryDelegate.buildProgress.buildStats?.progressPercentage ?? 0
    }
    
    private func startedAddingTracks() {
        buildProgressUpdateTask.startOrResume()
    }

    private func doneAddingTracks() {
        
        buildProgressUpdateTask.stop()
        window?.sheetParent?.endSheet(self.window!)
    }
}
