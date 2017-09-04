/*
    Entry point for the Aural Player application. Performs all interaction with the UI and delegates music player operations to PlayerDelegate.
 */
import Cocoa
import AVFoundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        // Set up key press handler
        NSEvent.addLocalMonitorForEvents(matching: NSEventMask.keyDown, handler: {(evt: NSEvent!) -> NSEvent in
            KeyPressHandler.handle(evt)
            return evt;
        });
        
        SyncMessenger.publishNotification(AppLoadedNotification.instance)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        
        SyncMessenger.publishNotification(AppExitNotification.instance)
        ObjectGraph.tearDown()
    }
}
