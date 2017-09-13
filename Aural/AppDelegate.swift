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
    
    override init() {
        
        super.init()
        
        // Configuration and initialization
        
        configureLogging()
        ObjectGraph.initialize()
        setUpKeyPressHandler()
    }
    
    // Make sure all logging is done to the app's log file
    private func configureLogging() {
        
        let allPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = allPaths.first!
        let pathForLog = documentsDirectory + ("/" + AppConstants.logFileName)
        
        freopen(pathForLog.cString(using: String.Encoding.ascii)!, "a+", stderr)
    }
    
    // Set up handler for keyboard input
    private func setUpKeyPressHandler() {
        
        NSEvent.addLocalMonitorForEvents(matching: NSEventMask.keyDown, handler: {(event: NSEvent!) -> NSEvent in
            KeyPressHandler.handle(event)
            return event;
        });
    }

    // Opens the application with a file (audio file or playlist)
    public func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        self.application(sender, openFiles: [filename])
        return true
    }
    
    // Opens the application with a set of files (audio files or playlists)
    public func application(_ sender: NSApplication, openFiles filenames: [String]) {
        
        filesToOpen.removeAll()
        for file in filenames {
            filesToOpen.append(URL(fileURLWithPath: file))
        }
        
        // If app has already launched, that means the app is "reopening" with the specified set of files
        if (appLaunched) {
            let reopenMsg = AppReopenedNotification(filesToOpen)
            SyncMessenger.publishNotification(reopenMsg)
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        appLaunched = true
        
        // Tell app components that the app has finished loading
        SyncMessenger.publishNotification(AppLoadedNotification(filesToOpen))
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplicationTerminateReply {
        
        // Broadcast a request to all app components that the app needs to exit. Check responses
        // to see if it is safe to exit
        let exitResponses = SyncMessenger.publishRequest(AppExitRequest.instance)
        
        for _response in exitResponses {
            
            let response = _response as! AppExitResponse
            
            // If any of the responses says it's not ok to exit, don't exit
            if (!response.okToExit) {
                return .terminateCancel
            }
        }
        
        // Ok to exit
        return .terminateNow
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        ObjectGraph.tearDown()
    }
}
