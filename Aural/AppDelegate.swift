/*
    Entry point for the Aural Player application. Performs all interaction with the UI and delegates music player operations to PlayerDelegate.
 */
import Cocoa
import AVFoundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    // (Optional) launch parameters: files to open upon launch (can be audio or playlist files)
    private var filesToOpen: [URL] = [URL]()
    
    // Flag that indicates whether the app has already finished launching (used when reopening the app with parameters)
    private var appLaunched: Bool = false
    
    public func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        
        filesToOpen.removeAll()
        filesToOpen.append(URL(fileURLWithPath: filename))
        
        if (appLaunched) {
            let reopenMsg = AppReopenedNotification(filesToOpen)
            SyncMessenger.publishNotification(reopenMsg)
        }
        
        return true
    }
    
    public func application(_ sender: NSApplication, openFiles filenames: [String]) {
        
        filesToOpen.removeAll()
        for file in filenames {
            filesToOpen.append(URL(fileURLWithPath: file))
        }
        
        if (appLaunched) {
            let reopenMsg = AppReopenedNotification(filesToOpen)
            SyncMessenger.publishNotification(reopenMsg)
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        // Set up key press handler
        NSEvent.addLocalMonitorForEvents(matching: NSEventMask.keyDown, handler: {(evt: NSEvent!) -> NSEvent in
            KeyPressHandler.handle(evt)
            return evt;
        });
        
        appLaunched = true
        SyncMessenger.publishNotification(AppLoadedNotification(filesToOpen))
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        
        SyncMessenger.publishNotification(AppExitNotification.instance)
        ObjectGraph.tearDown()
    }
}
