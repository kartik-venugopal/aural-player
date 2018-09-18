import Cocoa

class BarModeWindowController: NSWindowController, ActionMessageSubscriber {
    
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
        
        SyncMessenger.subscribe(actionTypes: [.dockTopLeft, .dockTopRight, .dockBottomLeft, .dockBottomRight], subscriber: self)
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
    
    @IBAction func dockTopLeftAction(_ sender: AnyObject) {
        
        let x = visibleFrame.minX
        let y = visibleFrame.maxY - theWindow.height
        
        theWindow.setFrameOrigin(NSPoint(x: x, y: y))
    }
    
    @IBAction func dockTopRightAction(_ sender: AnyObject) {
        
        let x = visibleFrame.maxX - theWindow.width
        let y = visibleFrame.maxY - theWindow.height
        
        theWindow.setFrameOrigin(NSPoint(x: x, y: y))
    }
    
    @IBAction func dockBottomLeftAction(_ sender: AnyObject) {
        
        let x = visibleFrame.minX
        let y = visibleFrame.minY
        
        theWindow.setFrameOrigin(NSPoint(x: x, y: y))
    }
    
    @IBAction func dockBottomRightAction(_ sender: AnyObject) {
        
        let x = visibleFrame.maxX - theWindow.width
        let y = visibleFrame.minY
        
        theWindow.setFrameOrigin(NSPoint(x: x, y: y))
    }
    
    func getID() -> String {
        return self.className
    }
    
    func consumeMessage(_ message: ActionMessage) {
        
        switch message.actionType {
            
        case .dockTopLeft: dockTopLeftAction(self)
            
        case .dockTopRight: dockTopRightAction(self)
            
        case .dockBottomLeft: dockBottomLeftAction(self)
            
        case .dockBottomRight: dockBottomRightAction(self)
            
        default: return
            
        }
    }
}
