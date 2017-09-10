/*
    Entry point for the Aural Player application. Performs all interaction with the UI and delegates music player operations to PlayerDelegate.
 */
import Cocoa
import AVFoundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    // (Optional) launch parameters: files to open (can be audio or playlist files)
    private var filesToOpen: [URL] = [URL]()
    
    public func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        filesToOpen.append(URL(fileURLWithPath: filename))
        return true
    }
    
    public func application(_ sender: NSApplication, openFiles filenames: [String]) {
        for file in filenames {
            filesToOpen.append(URL(fileURLWithPath: file))
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        // Set up key press handler
        NSEvent.addLocalMonitorForEvents(matching: NSEventMask.keyDown, handler: {(evt: NSEvent!) -> NSEvent in
            KeyPressHandler.handle(evt)
            return evt;
        });
        
        SyncMessenger.publishNotification(AppLoadedNotification(filesToOpen))
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        
        SyncMessenger.publishNotification(AppExitNotification.instance)
        ObjectGraph.tearDown()
    }
}
