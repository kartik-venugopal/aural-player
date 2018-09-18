import Cocoa

class BarModeWindowController: NSWindowController {
    
    // The box that encloses the Now Playing info section
    @IBOutlet weak var nowPlayingBox: NSBox!
    private lazy var nowPlayingView: NSView = ViewFactory.getBarModeNowPlayingView()
    
    // The box that encloses the player controls
    @IBOutlet weak var playerBox: NSBox!
    private lazy var playerView: NSView = ViewFactory.getBarModePlayerView()
    
    override var windowNibName: String? {return "BarMode"}
    
    private var theWindow: NSWindow {
        return self.window!
    }
    
    private lazy var visibleFrame: NSRect = {
        return NSScreen.main()!.visibleFrame
    }()
    
    override func windowDidLoad() {
        
        addSubViews()
        
        theWindow.isMovableByWindowBackground = true
        theWindow.level = Int(CGWindowLevelForKey(.floatingWindow))
    }
    
    private func addSubViews() {
        
        nowPlayingBox.addSubview(nowPlayingView)
        playerBox.addSubview(playerView)
    }
    
    // Quits the app
    @IBAction func quitAction(_ sender: AnyObject) {
        NSApp.terminate(self)
    }
    
    @IBAction func regularModeAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(AppModeActionMessage(.regularAppMode))
    }
    
    @IBAction func dockTopLeft(_ sender: AnyObject) {
        
        let x = visibleFrame.minX
        let y = visibleFrame.maxY - theWindow.height
        
        theWindow.setFrameOrigin(NSPoint(x: x, y: y))
    }
    
    @IBAction func dockTopRight(_ sender: AnyObject) {
        
        let x = visibleFrame.maxX - theWindow.width
        let y = visibleFrame.maxY - theWindow.height
        
        theWindow.setFrameOrigin(NSPoint(x: x, y: y))
    }
    
    @IBAction func dockBottomLeft(_ sender: AnyObject) {
        
        let x = visibleFrame.minX
        let y = visibleFrame.minY
        
        theWindow.setFrameOrigin(NSPoint(x: x, y: y))
    }
    
    @IBAction func dockBottomRight(_ sender: AnyObject) {
        
        let x = visibleFrame.maxX - theWindow.width
        let y = visibleFrame.minY
        
        theWindow.setFrameOrigin(NSPoint(x: x, y: y))
    }
}
