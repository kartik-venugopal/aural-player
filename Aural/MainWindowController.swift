import Cocoa

/*
    Window controller for the main window, but also controls the positioning and sizing of the playlist window. Performs any and all display (or hiding), positioning, alignment, resizing, etc. of both the main window and playlist window.
 */
class MainWindowController: NSWindowController, ActionMessageSubscriber {
    
    // Main application window. Contains the Now Playing info box, player controls, and effects panel. Not manually resizable. Changes size when toggling effects view.
    private var theWindow: NSWindow {
        return self.window!
    }
    
    // The box that encloses the Now Playing info section
    @IBOutlet weak var nowPlayingBox: NSBox!
    private lazy var nowPlayingView: NSView = ViewFactory.getNowPlayingView()
    
    // The box that encloses the player controls
    @IBOutlet weak var playerBox: NSBox!
    private lazy var playerView: NSView = ViewFactory.getPlayerView()
    
    // The box that encloses the Effects panel
    @IBOutlet weak var effectsBox: NSBox!
    private lazy var effectsView: NSView = ViewFactory.getEffectsView()
    
    // Buttons to toggle the playlist/effects views
    @IBOutlet weak var btnToggleEffects: OnOffImageButton!
    @IBOutlet weak var btnTogglePlaylist: OnOffImageButton!
    
    private var eventMonitor: Any?
    
    private var gestureHandler: GestureHandler!
    
    override var windowNibName: String? {return "MainWindow"}
    
    // MARK: Setup
    
    override func windowDidLoad() {
        
        initWindow()
        
        // Register a handler for trackpad/MagicMouse gestures
        
        gestureHandler = GestureHandler(self.window!)
        
        // Subscribe to various messages
        SyncMessenger.subscribe(actionTypes: [.toggleEffects, .togglePlaylist], subscriber: self)
    }
    
    override func showWindow(_ sender: Any?) {
        
        addSubViews()
        activateGestureHandler()
        
        let appState = ObjectGraph.getUIAppState()
        
        if (appState.hideEffects) {
            hideEffects()
        }
        
        btnToggleEffects.onIf(!appState.hideEffects)
        btnTogglePlaylist.onIf(!appState.hidePlaylist)
        
        super.showWindow(sender)
    }
    
    // Set window properties
    private func initWindow() {
        
        WindowState.window = theWindow
        theWindow.isMovableByWindowBackground = true
        theWindow.makeKeyAndOrderFront(self)
    }
    
    // Add the sub-views that make up the main window
    private func addSubViews() {
        
        nowPlayingBox.addSubview(nowPlayingView)
        playerBox.addSubview(playerView)
        effectsBox.addSubview(effectsView)
    }
    
    private func activateGestureHandler() {
        
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.swipe, .scrollWheel], handler: {(event: NSEvent!) -> NSEvent in
            
            self.gestureHandler.handle(event)
            return event;
        });
    }
    
    // Shows/hides the playlist window (by delegating)
    @IBAction func togglePlaylistAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(ViewActionMessage(.togglePlaylist))
    }
    
    private func togglePlaylist() {
        
        // This class does not actually show/hide the playlist view
        btnTogglePlaylist.toggle()
    }
    
    // Shows/hides the effects panel on the main window
    @IBAction func toggleEffectsAction(_ sender: AnyObject) {
        
        btnToggleEffects.toggle()
        effectsBox.isHidden = !effectsBox.isHidden
        
        WindowState.showingEffects = !WindowState.showingEffects
        
        // Resize window
        
        SyncMessenger.publishNotification(MainWindowResizingNotification.instance)
        
        var wFrame = theWindow.frame
        
        let newHeight: CGFloat = WindowState.showingEffects ? Dimensions.windowHeight_effectsOnly : Dimensions.windowHeight_compact

        let oldHeight = wFrame.height
        wFrame.size = NSMakeSize(theWindow.width, newHeight)
        wFrame.origin = wFrame.origin.applying(CGAffineTransform.init(translationX: 0, y: oldHeight - newHeight))
        
        theWindow.setFrame(wFrame, display: true)
    }
    
    private func hideEffects() {
        
        if (!effectsBox.isHidden) {
            toggleEffectsAction(self)
        }
    }
    
    @IBAction func statusBarModeAction(_ sender: AnyObject) {
        
        if eventMonitor != nil {
            NSEvent.removeMonitor(eventMonitor!)
            eventMonitor = nil
        }
        
        SyncMessenger.publishActionMessage(AppModeActionMessage(.statusBarAppMode))
    }
    
    @IBAction func floatingBarModeAction(_ sender: AnyObject) {
        
        if eventMonitor != nil {
            NSEvent.removeMonitor(eventMonitor!)
            eventMonitor = nil
        }
        
        SyncMessenger.publishActionMessage(AppModeActionMessage(.miniBarAppMode))
    }
    
    // Quits the app
    @IBAction func quitAction(_ sender: AnyObject) {
        NSApp.terminate(self)
    }
    
    // Minimizes the window (and any child windows)
    @IBAction func minimizeAction(_ sender: AnyObject) {
        theWindow.miniaturize(self)
    }
    
    func getID() -> String {
        return self.className
    }
    
    // MARK: Message handling
    
    func consumeMessage(_ message: ActionMessage) {
        
        switch message.actionType {
            
        case .toggleEffects: toggleEffectsAction(self)
            
        case .togglePlaylist: togglePlaylist()
            
        default: return
            
        }
    }
}
