/*
    Entry point for the Aural Player application. Performs high-level (application-level) operations.
 */
import Cocoa
import AVFoundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    // (Optional) launch parameters: files to open upon launch (can be audio or playlist files)
    private var filesToOpen: [URL] = [URL]()
    
    // Flag that indicates whether the app has already finished launching (used when reopening the app with launch parameters)
    private var appLaunched: Bool = false
    
    // Timestamp when the app last opened a set of files. This is used to consolidate multiple chunks of a file open operation into a single one (from the perspective of the user, it is one operation). This is necessary because a single Finder open operation results in multiple file open method calls here. Why ???
    private var lastFileOpenTime: Date?
    
    // A window of time within which multiple file open operations will be considered as chunks of one single operation
    private let fileOpenNotificationWindow_seconds: Double = 3
    
    override init() {
        
        super.init()
        
        // Configuration and initialization
        
        configureLogging()
        ObjectGraph.initialize()
    }
    
    // Make sure all logging is done to the app's log file
    private func configureLogging() {
        
        let allPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = allPaths.first!
        let pathForLog = documentsDirectory + ("/" + AppConstants.logFileName)
        
        freopen(pathForLog.cString(using: String.Encoding.ascii)!, "a+", stderr)
    }

    // Opens the application with a single file (audio file or playlist)
    public func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        self.application(sender, openFiles: [filename])
        return true
    }
    
    // Opens the application with a set of files (audio files or playlists)
    public func application(_ sender: NSApplication, openFiles filenames: [String]) {
        
        // Mark the timestamp of this operation
        let now = Date()
        
        // Clear previously added files from filesToOpen array, and add new files
        filesToOpen.removeAll()
        for file in filenames {
            filesToOpen.append(URL(fileURLWithPath: file))
        }
        
        // If app has already launched, that means the app is "reopening" with the specified set of files
        if (appLaunched) {
            
            // Check when the last file open operation was performed, to see if this is a chunk of a single larger operation
            let timeSinceLastFileOpen = lastFileOpenTime != nil ? now.timeIntervalSince(lastFileOpenTime!) : (fileOpenNotificationWindow_seconds + 1)
            
            // Publish a notification to the app that it needs to open the new set of files
            let reopenMsg = AppReopenedNotification(filesToOpen, timeSinceLastFileOpen < fileOpenNotificationWindow_seconds)
            SyncMessenger.publishNotification(reopenMsg)
        }
        
        // Update the lastFileOpenTime timestamp to the current time
        lastFileOpenTime = now
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        // Update the appLaunched flag
        appLaunched = true
        
        // Tell app components that the app has finished loading, and pass along any launch parameters (set of files to open)
        SyncMessenger.publishNotification(AppLoadedNotification(filesToOpen))
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        
        // Broadcast a request to all app components that the app needs to exit. Check responses to see if it is safe to exit. Some components may need to do some work before the app is able to safely exit, or cancel the exit operation altogether.
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
