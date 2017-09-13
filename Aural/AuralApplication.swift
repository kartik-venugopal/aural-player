/*
    Custom application class that performs configuration and initialization before the app launches
 */
import Cocoa

class AuralApplication: NSApplication {
    
    override init() {
        
        super.init()
        configureLogging()
        ObjectGraph.initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Make sure all logging is done to the app's log file
    private func configureLogging() {
        
        let allPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = allPaths.first!
        let pathForLog = documentsDirectory + ("/" + AppConstants.logFileName)
        
        freopen(pathForLog.cString(using: String.Encoding.ascii)!, "a+", stderr)
    }
}
