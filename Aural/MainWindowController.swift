import Cocoa

/*
    Window controller for the main window, but also controls the positioning and sizing of the playlist window. Performs any and all display (or hiding), positioning, alignment, resizing, etc. of both the main window and playlist window.
 */
class MainWindowController: NSWindowController, NSWindowDelegate, NSMenuDelegate, MessageSubscriber, ActionMessageSubscriber, ConstituentView {
    
    // Main application window. Contains the Now Playing info box, player controls, and effects panel. Not manually resizable. Changes size when toggling effects view.
    private var theWindow: SnappingWindow {
        return self.window! as! SnappingWindow
    }
    
    // The box that encloses the Now Playing info section
    @IBOutlet weak var containerBox: NSBox!
    private lazy var playerView: NSView = ViewFactory.playerView
    
    // Buttons to toggle the playlist/effects views
    @IBOutlet weak var btnToggleEffects: OnOffImageButton!
    @IBOutlet weak var btnTogglePlaylist: OnOffImageButton!
    @IBOutlet weak var btnLayout: NSPopUpButton!
    
    @IBOutlet weak var viewMenuButton: NSPopUpButton!
    
    private let preferences: ViewPreferences = ObjectGraph.preferencesDelegate.getPreferences().viewPreferences
    private lazy var layoutManager: LayoutManager = ObjectGraph.layoutManager
    
    private var eventMonitor: Any?
    
    private var gestureHandler: GestureHandler!
    
    override var windowNibName: String? {return "MainWindow"}
    
    // MARK: Setup
    
    // One-time setup
    override func windowDidLoad() {
        
        theWindow.setIsVisible(false)
        initWindow()
        theWindow.setIsVisible(false)
        
        // Register a handler for trackpad/MagicMouse gestures
        gestureHandler = GestureHandler(theWindow)
        
        AppModeManager.registerConstituentView(.regular, self)
    }
    
    func activate() {
        
        activateGestureHandler()
        initSubscriptions()
        
        // TODO: Restore remembered window location and views (effects/playlist)
    }
    
    func deactivate() {
        
        deactivateGestureHandler()
        removeSubscriptions()
        
        // TODO: Save window location and views (effects/playlist)
    }
    
    // Set window properties
    private func initWindow() {
        
        WindowState.mainWindow = theWindow
        theWindow.isMovableByWindowBackground = true
        theWindow.makeKeyAndOrderFront(self)
        
        addSubViews()
        
        let appState = ObjectGraph.appState.ui.windowLayout
        
        btnToggleEffects.onIf(appState.showEffects)
        btnTogglePlaylist.onIf(appState.showPlaylist)
        
        TextSizes.playerScheme = ObjectGraph.appState.ui.player.textSize
        changeTextSize()
    }
    
    // Add the sub-views that make up the main window
    private func addSubViews() {
        containerBox.addSubview(playerView)
    }
    
    private func activateGestureHandler() {
        
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.swipe, .scrollWheel], handler: {(event: NSEvent!) -> NSEvent in
            
            self.gestureHandler.handle(event)
            return event;
        });
    }
    
    private func deactivateGestureHandler() {
        
        if eventMonitor != nil {
            NSEvent.removeMonitor(eventMonitor!)
            eventMonitor = nil
        }
    }
    
    private func initSubscriptions() {
        
        // Subscribe to various messages
        SyncMessenger.subscribe(actionTypes: [.toggleEffects, .togglePlaylist, .changePlayerTextSize], subscriber: self)
        SyncMessenger.subscribe(messageTypes: [.layoutChangedNotification], subscriber: self)
    }
    
    private func removeSubscriptions() {
        
        SyncMessenger.unsubscribe(actionTypes: [.toggleEffects, .togglePlaylist, .changePlayerTextSize], subscriber: self)
        SyncMessenger.unsubscribe(messageTypes: [.layoutChangedNotification], subscriber: self)
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
        SyncMessenger.publishActionMessage(ViewActionMessage(.toggleEffects))
    }
    
    private func toggleEffects() {
        
        // This class does not actually show/hide the effects view
        btnToggleEffects.toggle()
    }
    
    @IBAction func btnLayoutAction(_ sender: NSPopUpButton) {
        layoutManager.layout(sender.titleOfSelectedItem!)
    }
    
    private func layoutChanged(_ message: LayoutChangedNotification) {
        
        btnToggleEffects.onIf(message.showingEffects)
        btnTogglePlaylist.onIf(message.showingPlaylist)
    }
    
//    @IBAction func floatingBarModeAction(_ sender: AnyObject) {
//        SyncMessenger.publishActionMessage(AppModeActionMessage(.miniBarAppMode))
//    }
    
    // Quits the app
    @IBAction func quitAction(_ sender: AnyObject) {
        NSApp.terminate(self)
    }
    
    // Minimizes the window (and any child windows)
    @IBAction func minimizeAction(_ sender: AnyObject) {
        theWindow.miniaturize(self)
    }
    
    // MARK: Window delegate
    
    func windowDidMove(_ notification: Notification) {
        
        // Check if movement was user-initiated (flag on window)
        if !theWindow.userMovingWindow {return}
        
        if preferences.snapToScreen {
            UIUtils.checkForSnapToVisibleFrame(theWindow)
        }
    }
    
    // MARK: Menu delegate
    
    // When the menu is about to open, set the menu item states according to the current window/view state
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        // Remove all custom presets (all items before the first separator)
        while !btnLayout.item(at: 1)!.isSeparatorItem {
            btnLayout.removeItem(at: 1)
        }
        
        // Recreate the custom layout items
        WindowLayouts.userDefinedLayouts.forEach({
            self.btnLayout.insertItem(withTitle: $0.name, at: 1)
        })
    }
    
    private func changeTextSize() {
        
        btnLayout.font = TextSizes.playerMenuFont
        viewMenuButton.font = TextSizes.playerMenuFont
    }
    
    // MARK: Message handling
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        switch notification.messageType {
            
        case .layoutChangedNotification:
            
            layoutChanged(notification as! LayoutChangedNotification)
            
        default: return
            
        }
    }
    
    func consumeMessage(_ message: ActionMessage) {
        
        switch message.actionType {
            
        case .toggleEffects: toggleEffects()
            
        case .togglePlaylist: togglePlaylist()
            
        case .changePlayerTextSize: changeTextSize()
            
        default: return
            
        }
    }
    
    var subscriberId: String {
        return self.className
    }
}
