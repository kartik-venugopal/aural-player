import Cocoa

class BarModeWindowController: NSWindowController, MessageSubscriber, ActionMessageSubscriber, NSWindowDelegate {
    
    // The box that encloses the Now Playing info section
    @IBOutlet weak var nowPlayingBox: NSBox!
    private lazy var nowPlayingView: NSView = ViewFactory.getBarModeNowPlayingView()
    
    // The box that encloses the player controls
    @IBOutlet weak var playerBox: NSBox!
    private lazy var playerView: NSView = ViewFactory.getBarModePlayerView()
    
    private let expandedWidth: CGFloat = 560
    private let collapsedWidth: CGFloat = 306
    
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
        
        SyncMessenger.subscribe(messageTypes: [.barModeWindowMouseEntered, .barModeWindowMouseExited], subscriber: self)
        
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
    
    private func hidePlayer() {
        resizeWindow(collapsedWidth)
    }
    
    private func resizeWindow(_ newWidth: CGFloat) {
        
        var wFrame = theWindow.frame
        
        wFrame.size = NSMakeSize(newWidth, theWindow.height)
        wFrame.origin = theWindow.origin
        
        theWindow.setFrame(wFrame, display: true, animate: true)
    }
    
    @IBAction func dockTopLeftAction(_ sender: AnyObject) {
        
        hidePlayer()
        
        let x = visibleFrame.minX
        let y = visibleFrame.maxY - theWindow.height
        
        theWindow.setFrameOrigin(NSPoint(x: x, y: y))
    }
    
    @IBAction func dockTopRightAction(_ sender: AnyObject) {
        
        hidePlayer()
        
        let x = visibleFrame.maxX - theWindow.width
        let y = visibleFrame.maxY - theWindow.height
        
        theWindow.setFrameOrigin(NSPoint(x: x, y: y))
    }
    
    @IBAction func dockBottomLeftAction(_ sender: AnyObject) {
        
        hidePlayer()
        
        let x = visibleFrame.minX
        let y = visibleFrame.minY
        
        theWindow.setFrameOrigin(NSPoint(x: x, y: y))
    }
    
    @IBAction func dockBottomRightAction(_ sender: AnyObject) {
        
        hidePlayer()
        
        let x = visibleFrame.maxX - theWindow.width
        let y = visibleFrame.minY
        
        theWindow.setFrameOrigin(NSPoint(x: x, y: y))
    }
    
    private func showPlayer() {
        resizeWindow(expandedWidth)
        ensureWindowVisible()
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
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        switch notification.messageType {
            
        case .barModeWindowMouseEntered:
            
            showPlayer()
            
        case .barModeWindowMouseExited:
            
            hidePlayer()
            
        default:    return
            
        }
    }
    
    func processRequest(_ request: RequestMessage) -> ResponseMessage {
        return EmptyResponse.instance
    }
    
    private func checkIfWindowVisible(_ window: NSWindow) -> (visible: Bool, dx: CGFloat, dy: CGFloat) {
        
        var dx: CGFloat = 0, dy: CGFloat = 0
        
        if (window.x < visibleFrame.minX) {
            dx = visibleFrame.minX - window.x
        } else if (window.maxX > visibleFrame.maxX) {
            dx = -(window.maxX - visibleFrame.maxX)
        }
        
        if (window.y < visibleFrame.minY) {
            dy = visibleFrame.minY - window.y
        } else if (window.maxY > visibleFrame.maxY) {
            dy = -(window.maxY - visibleFrame.maxY)
        }
        
        return (dx == 0 && dy == 0, dx, dy)
    }
    
    private func ensureWindowVisible() {
        
        let visible = checkIfWindowVisible(theWindow)
        if (!visible.visible) {
            moveWindow(visible.dx, visible.dy)
        }
    }
    
    private func moveWindow(_ dx: CGFloat, _ dy: CGFloat) {
        theWindow.setFrameOrigin(theWindow.origin.applying(CGAffineTransform.init(translationX: dx, y: dy)))
    }
}
