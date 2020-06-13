import Cocoa

/*
    Window controller for the main application window.
 */
class MainWindowController: NSWindowController, MessageSubscriber, ActionMessageSubscriber {
    
    // Main application window. Contains the Now Playing info box and player controls. Not resizable.
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
    @IBOutlet weak var btnSettingsMenu: NSPopUpButton!
    
    @IBOutlet weak var settingsMenuIconItem: TintedIconMenuItem!
    
    private var eventMonitor: Any?
    
    private var gestureHandler: GestureHandler!
    
    override var windowNibName: String? {return "MainWindow"}
    
    // MARK: Setup
    
    // One-time setup
    override func windowDidLoad() {
        
        theWindow.setIsVisible(false)
        initWindow()
        theWindow.setIsVisible(false)
        
        theWindow.delegate = WindowManager.windowDelegate
        
        activateGestureHandler()
        initSubscriptions()
    }
    
    // Set window properties
    private func initWindow() {
        
        theWindow.isMovableByWindowBackground = true
        theWindow.makeKeyAndOrderFront(self)
        
        addSubViews()
        
        let appState = ObjectGraph.appState.ui.windowLayout
        
        [btnQuit, btnMinimize].forEach({$0?.tintFunction = {return Colors.viewControlButtonColor}})
        
        [btnToggleEffects, btnTogglePlaylist].forEach({
            $0?.onStateTintFunction = {return Colors.viewControlButtonColor}
            $0?.offStateTintFunction = {return Colors.toggleButtonOffStateColor}
        })
        
        logoImage.tintFunction = {return Colors.appLogoColor}
        
        btnToggleEffects.onIf(appState.showEffects)
        btnTogglePlaylist.onIf(appState.showPlaylist)
        
        changeTextSize()
        applyColorScheme(ColorSchemes.systemScheme)
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
        SyncMessenger.subscribe(actionTypes: [.toggleEffects, .togglePlaylist, .changePlayerTextSize, .changeBackgroundColor, .changeViewControlButtonColor, .changeToggleButtonOffStateColor, .changeAppLogoColor, .applyColorScheme], subscriber: self)
        
        Messenger.subscribe(self, .windowLayoutChanged, self.windowLayoutChanged(_:))
    }
    
    // Shows/hides the playlist window (by delegating)
    @IBAction func togglePlaylistAction(_ sender: AnyObject) {
        togglePlaylist()
    }
    
    private func togglePlaylist() {

        WindowManager.togglePlaylist()
        btnTogglePlaylist.toggle()
    }
    
    // Shows/hides the effects panel on the main window
    @IBAction func toggleEffectsAction(_ sender: AnyObject) {
        toggleEffects()
    }
    
    private func toggleEffects() {
        
        WindowManager.toggleEffects()
        btnToggleEffects.toggle()
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
        btnSettingsMenu.font = Fonts.Player.menuFont
    }
    
    private func applyColorScheme(_ scheme: ColorScheme) {
        
        changeBackgroundColor(scheme.general.backgroundColor)
        changeViewControlButtonColor(scheme.general.viewControlButtonColor)
        changeToggleButtonOffStateColor(scheme.general.toggleButtonOffStateColor)
        changeAppLogoColor(scheme.general.appLogoColor)
    }
    
    private func changeBackgroundColor(_ color: NSColor) {
        
        rootContainerBox.fillColor = color

        containerBox.fillColor = color
        containerBox.isTransparent = !color.isOpaque
    }
    
    private func changeViewControlButtonColor(_ color: NSColor) {
        
        [btnQuit, btnMinimize, btnTogglePlaylist, btnToggleEffects, settingsMenuIconItem].forEach({
            ($0 as? Tintable)?.reTint()
        })
    }
    
    private func changeToggleButtonOffStateColor(_ color: NSColor) {
        
        // These are the only 2 buttons that have off states
        [btnTogglePlaylist, btnToggleEffects].forEach({
            $0.reTint()
        })
    }
    
    private func changeAppLogoColor(_ color: NSColor) {
        logoImage.reTint()
    }
    
    // MARK: Message handling
    
    func windowLayoutChanged(_ notification: WindowLayoutChangedNotification) {
        
        btnToggleEffects.onIf(notification.showingEffects)
        btnTogglePlaylist.onIf(notification.showingPlaylist)
    }
    
    func consumeMessage(_ message: ActionMessage) {
        
        switch message.actionType {
            
        case .toggleEffects: toggleEffects()
            
        case .togglePlaylist: togglePlaylist()
            
        case .changePlayerTextSize: changeTextSize()
            
        case .changeBackgroundColor:
            
            if let bkColor = (message as? ColorSchemeComponentActionMessage)?.color {
                changeBackgroundColor(bkColor)
            }
            
        case .changeAppLogoColor:
            
            if let logoTextColor = (message as? ColorSchemeComponentActionMessage)?.color {
                changeAppLogoColor(logoTextColor)
            }
            
        case .changeViewControlButtonColor:
            
            if let ctrlColor = (message as? ColorSchemeComponentActionMessage)?.color {
                changeViewControlButtonColor(ctrlColor)
            }
            
        case .changeToggleButtonOffStateColor:
            
            if let ctrlColor = (message as? ColorSchemeComponentActionMessage)?.color {
                changeToggleButtonOffStateColor(ctrlColor)
            }
            
        case .applyColorScheme:
            
            if let scheme = (message as? ColorSchemeActionMessage)?.scheme {
                applyColorScheme(scheme)
            }
            
        default: return
            
        }
    }
}
