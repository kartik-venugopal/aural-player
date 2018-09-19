import Cocoa

class BarModeWindowController: NSWindowController, MessageSubscriber, ActionMessageSubscriber, NSWindowDelegate, ConstituentView {
    
    // The box that encloses the Now Playing info section
    @IBOutlet weak var nowPlayingBox: NSBox!
    private lazy var nowPlayingView: NSView = ViewFactory.getBarModeNowPlayingView()
    
    // The box that encloses the player controls
    @IBOutlet weak var playerBox: NSBox!
    private lazy var playerView: NSView = ViewFactory.getBarModePlayerView()
    
    @IBOutlet weak var btnDockTopLeft: OnOffImageButton!
    @IBOutlet weak var btnDockTopRight: OnOffImageButton!
    @IBOutlet weak var btnDockBottomLeft: OnOffImageButton!
    @IBOutlet weak var btnDockBottomRight: OnOffImageButton!
    
    private var dockButtons: [OnOffImageButton] = []
    
    private let expandedWidth: CGFloat = 560
    private let collapsedWidth: CGFloat = 306
    
    override var windowNibName: String? {return "BarMode"}
    
    private var theWindow: NSWindow {
        return self.window!
    }
    
    private lazy var visibleFrame: NSRect = {
        return NSScreen.main()!.visibleFrame
    }()
    
    private var dockState: DockState = .none
    private var appMovingWindow: Bool = false
    
    override func windowDidLoad() {
        
        addSubViews()
        dockButtons = [btnDockTopLeft, btnDockTopRight, btnDockBottomLeft, btnDockBottomRight]
        
        // TODO: Later, this should be configurable (not always not docked)
        dockButtons.forEach({$0.off()})
        
        theWindow.isMovableByWindowBackground = true
        theWindow.level = Int(CGWindowLevelForKey(.floatingWindow))
        
        AppModeManager.registerConstituentView(.miniBar, self)
    }
    
    func activate() {
        initSubscriptions()
        hidePlayer()
    }
    
    func deactivate() {
        removeSubscriptions()
    }
    
    private func initSubscriptions() {
        
        SyncMessenger.subscribe(messageTypes: [.barModeWindowMouseEntered, .barModeWindowMouseExited], subscriber: self)
        
        SyncMessenger.subscribe(actionTypes: [.dockTopLeft, .dockTopRight, .dockBottomLeft, .dockBottomRight], subscriber: self)
    }
    
    private func removeSubscriptions() {

        SyncMessenger.unsubscribe(messageTypes: [.barModeWindowMouseEntered, .barModeWindowMouseExited], subscriber: self)
        
        SyncMessenger.unsubscribe(actionTypes: [.dockTopLeft, .dockTopRight, .dockBottomLeft, .dockBottomRight], subscriber: self)
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
    
    private func showPlayer() {
        resizeWindow(expandedWidth)
        ensureWindowVisible()
    }
    
    private func hidePlayer(reDockWindow: Bool = true) {
        
        resizeWindow(collapsedWidth)
        
        if reDockWindow {
            reDock()
        }
    }
    
    private func reDock() {
        
        switch dockState {
            
        case .none, .topLeft, .bottomLeft: return
            
        case .topRight: doDockTopRight()
            
        case .bottomRight:  doDockBottomRight()
            
        }
    }
    
    private func resizeWindow(_ newWidth: CGFloat, animate: Bool = false) {
        
        var wFrame = theWindow.frame
        
        wFrame.size = NSMakeSize(newWidth, theWindow.height)
        wFrame.origin = theWindow.origin
        
        // TODO: Make dock bar auto-hide animations configurable ?
        theWindow.setFrame(wFrame, display: true, animate: animate)
    }
    
    @IBAction func dockTopLeftAction(_ sender: AnyObject) {
        
        hidePlayer()
        
        let x = visibleFrame.minX
        let y = visibleFrame.maxY - theWindow.height
        
        appMovingWindow = true
        theWindow.setFrameOrigin(NSPoint(x: x, y: y))
        appMovingWindow = false
        
        dockState = .topLeft
        
        dockButtons.forEach({$0.off()})
        btnDockTopLeft.on()
    }
    
    @IBAction func dockTopRightAction(_ sender: AnyObject) {
        
        hidePlayer()
        doDockTopRight()
        dockState = .topRight
        
        dockButtons.forEach({$0.off()})
        btnDockTopRight.on()
    }
    
    private func doDockTopRight() {
        
        let x = visibleFrame.maxX - theWindow.width
        let y = visibleFrame.maxY - theWindow.height
        
        appMovingWindow = true
        theWindow.setFrameOrigin(NSPoint(x: x, y: y))
        appMovingWindow = false
    }
    
    private func doDockBottomRight() {
        
        let x = visibleFrame.maxX - theWindow.width
        let y = visibleFrame.minY
        
        appMovingWindow = true
        theWindow.setFrameOrigin(NSPoint(x: x, y: y))
        appMovingWindow = false
    }
    
    @IBAction func dockBottomLeftAction(_ sender: AnyObject) {
        
        hidePlayer()
        
        let x = visibleFrame.minX
        let y = visibleFrame.minY
        
        appMovingWindow = true
        theWindow.setFrameOrigin(NSPoint(x: x, y: y))
        appMovingWindow = false
        
        dockState = .bottomLeft
        
        dockButtons.forEach({$0.off()})
        btnDockBottomLeft.on()
    }
    
    @IBAction func dockBottomRightAction(_ sender: AnyObject) {
        
        hidePlayer()
        doDockBottomRight()
        
        dockState = .bottomRight
        
        dockButtons.forEach({$0.off()})
        btnDockBottomRight.on()
    }
    
    // Notifies when the window has been moved
    func windowDidMove(_ notification: Notification) {
        if (!appMovingWindow) {
            dockState = .none
            dockButtons.forEach({$0.off()})
        }
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
        appMovingWindow = true
        theWindow.setFrameOrigin(theWindow.origin.applying(CGAffineTransform.init(translationX: dx, y: dy)))
        appMovingWindow = false
    }
    
    // MARK: Message handling
    
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
}

enum DockState {
    
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
    case none
}
