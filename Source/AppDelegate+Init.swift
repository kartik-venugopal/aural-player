//
//  AppDelegate+Init.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

/// Flag that indicates whether the app has already finished launching (used when reopening the app with launch parameters)
fileprivate var appLaunched: Bool = false

fileprivate var appSetupWindowController: AppSetupWindowController = .init()

fileprivate var persistenceTaskExecutor: RepeatingTaskExecutor!

/// Timestamp when the app last opened a set of files. This is used to consolidate multiple chunks of a file open operation into a single one (from the perspective of the user, it is one operation). This is necessary because a single Finder open operation results in multiple file open method calls here. Why ???
fileprivate var lastFileOpenTime: Date?

fileprivate var initOpQueue: OperationQueue = OperationQueue(opCount: 2, qos: .userInteractive)

extension AppDelegate {
    
    /// A window of time within which multiple file open operations will be considered as chunks of one single operation
    private static let fileOpenNotificationWindow_seconds: TimeInterval = 3
    
    /// Measured in seconds
    static let persistenceTaskInterval: Int = 60
    
    func openApp(withFiles filenames: [String]) {
        
        // Mark the timestamp of this operation
        let now = Date()
        
        // Clear previously added files from filesToOpen array, and add new files
        filesToOpen = filenames.map {URL(fileURLWithPath: $0)}
        
        // If need to play entire parent folder, expand file(s) into parent folder
        if preferences.playQueuePreferences.playParentFolder {
            
            let firstOpenedFile = filesToOpen.first
            let parents = Set(filesToOpen.map {$0.parentDir})
            
            if parents.count == 1, let parent = parents.first, let filesInParentDir = parent.children?.filter({$0.isSupportedAudioFile}) {
                
                filesToOpen = filesInParentDir
                filesToOpen.sort(by: {$0.lastPathComponent < $1.lastPathComponent})
                
                if let firstOpenedFile, let index = filesToOpen.firstIndex(of: firstOpenedFile) {
                    filesToOpen.removeAndInsertItem(index, 0)
                }
            }
        }
        
        // If app has already launched, that means the app is "reopening" with the specified set of files
        if appLaunched {
            
            // Check when the last file open operation was performed, to see if this is a chunk of a single larger operation
            
            var isDuplicateNotification: Bool = false
            
            if let lastFileOpenTime = lastFileOpenTime {
                isDuplicateNotification = now.timeIntervalSince(lastFileOpenTime) < Self.fileOpenNotificationWindow_seconds
            }
            
            // Publish a notification to the app that it needs to open the new set of files
            let reopenMsg = AppReopenedNotification(filesToOpen: filesToOpen, isDuplicateNotification: isDuplicateNotification)
            messenger.publish(reopenMsg)
        }
        
        // Update the lastFileOpenTime timestamp to the current time
        lastFileOpenTime = now
    }
    
    func performAppSetup() {
        
        messenger.subscribe(to: .appSetup_completed) {
            
            if appSetup.setupCompleted {
                
                colorSchemesManager.applyScheme(named: appSetup.colorSchemePreset.name)
                fontSchemesManager.applyScheme(named: appSetup.fontSchemePreset.name)
                
//                library.sourceFolders = [appSetup.librarySourceFolder]
            }
            
            self.postLaunch()
        }
        
        appSetupWindowController.showWindow(self)
    }
    
    func postLaunch() {
        
        appInitializer.initializeApp {
            
            // Update the appLaunched flag
            appLaunched = true
            
            // Tell app components that the app has finished launching, and pass along any launch parameters (set of files to open)
            self.messenger.publish(.Application.launched, payload: self.filesToOpen)
        }
    }
}
