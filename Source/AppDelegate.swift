//
//  AppDelegate.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

///
/// Entry point for the Aural Player application. Performs application life-cycle functions and allows launching of the app with specific files
/// from Finder.
///
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    /// (Optional) launch parameters: files to open upon launch (can be audio or playlist files)
    private var filesToOpen: [URL] = []
    
    /// Flag that indicates whether the app has already finished launching (used when reopening the app with launch parameters)
    private var appLaunched: Bool = false
    
    /// Timestamp when the app last opened a set of files. This is used to consolidate multiple chunks of a file open operation into a single one (from the perspective of the user, it is one operation). This is necessary because a single Finder open operation results in multiple file open method calls here. Why ???
    private var lastFileOpenTime: Date?
    
    /// A window of time within which multiple file open operations will be considered as chunks of one single operation
    private let fileOpenNotificationWindow_seconds: Double = 3
    
    private lazy var messenger = Messenger(for: self)
    
    override init() {
        
        super.init()
//        configureLogging()
    }
    
    /// Make sure all logging is done to the app's log file
    private func configureLogging() {
        
        if let logFileCString = FilesAndPaths.logFile.path.cString(using: .ascii) {
            freopen(logFileCString, "a+", stderr)
        }
    }

    /// Presents the application's user interface upon app startup.
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        objectGraph.appModeManager.presentApp()
        
        // Update the appLaunched flag
        appLaunched = true
        
        // Tell app components that the app has finished launching, and pass along any launch parameters (set of files to open)
        messenger.publish(.application_launched, payload: filesToOpen)
    }
    
    /// Opens the application with a single file (audio file or playlist)
    public func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        
        self.application(sender, openFiles: [filename])
        return true
    }
    
    /// Opens the application with a set of files (audio files or playlists)
    public func application(_ sender: NSApplication, openFiles filenames: [String]) {
        
        // Mark the timestamp of this operation
        let now = Date()
        
        // Clear previously added files from filesToOpen array, and add new files
        filesToOpen = filenames.map {URL(fileURLWithPath: $0)}
        
        // If app has already launched, that means the app is "reopening" with the specified set of files
        if appLaunched {
            
            // Check when the last file open operation was performed, to see if this is a chunk of a single larger operation
            let timeSinceLastFileOpen = lastFileOpenTime != nil ? now.timeIntervalSince(lastFileOpenTime!) : (fileOpenNotificationWindow_seconds + 1)
            
            // Publish a notification to the app that it needs to open the new set of files
            let reopenMsg = AppReopenedNotification(filesToOpen: filesToOpen, isDuplicateNotification: timeSinceLastFileOpen < fileOpenNotificationWindow_seconds)
            
            messenger.publish(reopenMsg)
        }
        
        // Update the lastFileOpenTime timestamp to the current time
        lastFileOpenTime = now
    }
    
    /// Tears down app components in preparation for app termination.
    func applicationWillTerminate(_ aNotification: Notification) {
        
        // Broadcast a notification to all app components that the app will exit.
        // This call is synchronous, i.e. it will block till all observers have
        // finished saving their state or performing any cleanup.
        messenger.publish(.application_willExit)
        
        // Perform a final shutdown.
        objectGraph.tearDown()
    }
}

let objectGraph: ObjectGraph = ObjectGraph.instance
