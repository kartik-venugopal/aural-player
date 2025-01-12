//
//  FolderMonitor.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

///
/// Source: https://medium.com/over-engineering/monitoring-a-folder-for-changes-in-ios-dc3f8614f902
///
class FolderMonitor {
    
    // MARK: Properties
    
    /// URL for the directory being monitored.
    let url: URL
    private let fileWatcher: FileWatcher
    
    private static let fileManager: FileManager = .default
    private lazy var messenger: Messenger = .init(for: self)
    
    // MARK: Initializers
    
    init(url: URL) {
        
        self.url = url
        self.fileWatcher = FileWatcher(urls: [url])
    }
    
    // MARK: Monitoring
    
    /// Listen for changes to the directory (if we are not already).
    func startMonitoring() {
        
        fileWatcher.callback = { (event: FileWatcherEvent) in
            
            let url = URL(fileURLWithPath: event.path)
            guard url.isSupportedFile else {return}
            
            if !url.exists {
                self.messenger.publish(FileSystemFolderChangedNotification(notificationName: .tuneBrowser_fileDeleted, affectedURL: url))
                
            } else if event.fileCreated || event.fileRenamed {
                self.messenger.publish(FileSystemFolderChangedNotification(notificationName: .tuneBrowser_fileAdded, affectedURL: url))
            }
            
            // TODO: Handle dir events (eg. dirCreated, ...)
        }
        
        fileWatcher.start() // start monitoring
    }
    
    /// Stop listening for changes to the directory, if the source has been created.
    func stopMonitoring() {
        
    }
}
