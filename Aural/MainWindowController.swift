import Cocoa

/*
    Window controller for the main window, but also controls the positioning and sizing of the playlist window. Performs any and all display (or hiding), positioning, alignment, resizing, etc. of both the main window and playlist window.
 */
class MainWindowController: NSWindowController, MessageSubscriber, ActionMessageSubscriber {
    
    // Main application window. Contains the Now Playing info box, player controls, and effects panel. Not manually resizable. Changes size when toggling effects view.
    private var theWindow: SnappingWindow {
        return self.window! as! SnappingWindow
    }
    
    @IBOutlet weak var logoImage: TintedImageView!
    
    // The box that encloses the Now Playing info section
    @IBOutlet weak var rootContainerBox: NSBox!
    @IBOutlet weak var containerBox: NSBox!
    private lazy var playerView: NSView = ViewFactory.playerView
    
    @IBOutlet weak var btnQuit: TintedImageButton!
    @IBOutlet weak var btnMinimize: TintedImageButton!
    
    // Buttons to toggle the playlist/effects views
    @IBOutlet weak var btnToggleEffects: OnOffImageButton!
    @IBOutlet weak var btnTogglePlaylist: OnOffImageButton!
    @IBOutlet weak var btnLayout: NSPopUpButton!
    @IBOutlet weak var btnViewMenu: NSPopUpButton!
    
    @IBOutlet weak var viewMenuIconItem: TintedIconMenuItem!
    @IBOutlet weak var layoutMenuIconItem: TintedIconMenuItem!
    
    private var eventMonitor: Any?
    
    private var gestureHandler: GestureHandler!
    
    override var windowNibName: String? {return "MainWindow"}
    
    private lazy var colorsDialog: ColorSchemesWindowController = ColorSchemesWindowController()
    
    @IBAction func showColorsAction(_ sender: AnyObject) {
        colorsDialog.window?.setIsVisible(true)
    }
    
    // MARK: Setup
    
    // One-time setup
    override func windowDidLoad() {
        
        theWindow.setIsVisible(false)
        initWindow()
        theWindow.setIsVisible(false)
        
        theWindow.delegate = ObjectGraph.windowManager
        
        activateGestureHandler()
        initSubscriptions()
    }
    
    // Set window properties
    private func initWindow() {
        
        theWindow.isMovableByWindowBackground = true
        theWindow.makeKeyAndOrderFront(self)
        
        addSubViews()
        
        let appState = ObjectGraph.appState.ui.windowLayout
        
        btnToggleEffects.onIf(appState.showEffects)
        btnTogglePlaylist.onIf(appState.showPlaylist)
        
        changeTextSize()
        logoImage.tintFunction = {return ColorScheme.systemScheme.logoTextColor}
    }
    
    // Add the sub-views that make up the main window
    private func addSubViews() {
        containerBox.addSubview(playerView)
    }
    
    private func activateGestureHandler() {
        
        // Register a handler for trackpad/MagicMouse gestures
        gestureHandler = GestureHandler(theWindow)
        
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .swipe, .scrollWheel], handler: {(event: NSEvent) -> NSEvent? in
            return self.gestureHandler.handle(event) ? nil : event;
        });
    }
    
    private func initSubscriptions() {
        
        // Subscribe to various messages
        SyncMessenger.subscribe(actionTypes: [.toggleEffects, .togglePlaylist, .changePlayerTextSize, .changeBackgroundColor, .changeControlButtonColor, .changeControlButtonOffStateColor, .changeLogoTextColor], subscriber: self)
        
        SyncMessenger.subscribe(messageTypes: [.layoutChangedNotification], subscriber: self)
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
    
    private func layoutChanged(_ message: LayoutChangedNotification) {
        
        btnToggleEffects.onIf(message.showingEffects)
        btnTogglePlaylist.onIf(message.showingPlaylist)
    }
    
    // Quits the app
    @IBAction func quitAction(_ sender: AnyObject) {
        NSApp.terminate(self)
    }
    
    // Minimizes the window (and any child windows)
    @IBAction func minimizeAction(_ sender: AnyObject) {
        theWindow.miniaturize(self)
    }
    
    private func changeTextSize() {
        
        btnLayout.font = Fonts.Player.menuFont
        btnViewMenu.font = Fonts.Player.menuFont
    }
    
    private func changeBackgroundColor(_ color: NSColor) {
        
        rootContainerBox.fillColor = color
        
        containerBox.fillColor = color
        containerBox.isTransparent = !color.isOpaque
    }
    
    private func changeControlButtonColor(_ color: NSColor) {
        
        [btnQuit, btnMinimize, btnTogglePlaylist, btnToggleEffects, viewMenuIconItem, layoutMenuIconItem].forEach({
            ($0 as? Tintable)?.reTint()
        })
    }
    
    private func changeLogoTextColor(_ color: NSColor) {
        logoImage.reTint()
    }
    
    // MARK: Message handling
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        if let layoutChangedMsg = notification as? LayoutChangedNotification {
            layoutChanged(layoutChangedMsg)
        }
    }
    
    func consumeMessage(_ message: ActionMessage) {
        
        switch message.actionType {
            
        case .toggleEffects: toggleEffects()
            
        case .togglePlaylist: togglePlaylist()
            
        case .changePlayerTextSize: changeTextSize()
            
        case .changeBackgroundColor:
            
            if let bkColor = (message as? ColorSchemeActionMessage)?.color {
                changeBackgroundColor(bkColor)
            }
            
        case .changeControlButtonColor:
            
            if let ctrlColor = (message as? ColorSchemeActionMessage)?.color {
                changeControlButtonColor(ctrlColor)
            }
            
        case .changeLogoTextColor:
            
            if let logoTextColor = (message as? ColorSchemeActionMessage)?.color {
                changeLogoTextColor(logoTextColor)
            }
            
        default: return
            
        }
    }
    
    var subscriberId: String {
        return self.className
    }
}
