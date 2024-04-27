//
//  AppDelegate.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
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
    
    lazy var messenger = Messenger(for: self)
    
    override init() {
        
        print("AppDelegate.init(): \(Date.nowTimestampString)")
        
        super.init()
        
        System.openFilesLimit = 10000
        configureLogging()
        
//        copyOverV3State()
    }
    
    private func copyOverV3State() {
        
        let src = URL(fileURLWithPath: "/Users/kven/Music/aural/state.json")
        let dest = URL(fileURLWithPath: "/Users/kven/Music/aural4/state.json")
        
        if dest.exists {
            dest.rename(to: URL(fileURLWithPath: "/Users/kven/Music/aural4/muthu_\(Date().serializableStringAsHMS)_state.json"))
        }
        
        try? FileManager.default.copyItem(at: src, to: dest)
    }
    
    /// Make sure all logging is done to the app's log file
    private func configureLogging() {
        
        if let logFileCString = FilesAndPaths.logFile.path.cString(using: .ascii) {
            freopen(logFileCString, "a+", stderr)
        }
    }
    
    /// Presents the application's user interface upon app startup.
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        initializeMetadataComponents()
        
        if appSetup.setupRequired {
            performAppSetup()
            
        } else {
            postLaunch()
        }
        
//        SearchWindowController.shared.showWindow(self)
    }
    
    /// Opens the application with a single file (audio file or playlist)
    public func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        
        self.application(sender, openFiles: [filename])
        return true
    }
    
    /// Opens the application with a set of files (audio files or playlists)
    public func application(_ sender: NSApplication, openFiles filenames: [String]) {
        openApp(withFiles: filenames)
    }
    
    /// Tears down app components in preparation for app termination.
    func applicationWillTerminate(_ aNotification: Notification) {
        
        // Broadcast a notification to all app components that the app will exit.
        // This call is synchronous, i.e. it will block till all observers have
        // finished saving their state or performing any cleanup.
        messenger.publish(.Application.willExit)
        
        // Perform a final shutdown.
        tearDown()
    }
}
