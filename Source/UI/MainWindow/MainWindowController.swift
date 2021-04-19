import Cocoa

/*
    Window controller for the main application window.
 */
class MainWindowController: NSWindowController, NotificationSubscriber, Destroyable {
    
    deinit {
        print("\nDeinited \(self.className)")
    }
    
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
    @IBOutlet weak var btnStatusBarMode: TintedImageButton!
    
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
        
        activateGestureHandler()
        initSubscriptions()
    }
    
    // Set window properties
    private func initWindow() {
        
        theWindow.isMovableByWindowBackground = true
        theWindow.makeKeyAndOrderFront(self)
        
        addSubViews()
        
        let persistentState = ObjectGraph.persistentState.ui.windowLayout
        
        [btnQuit, btnMinimize, btnStatusBarMode].forEach({$0?.tintFunction = {return Colors.viewControlButtonColor}})
        
        [btnToggleEffects, btnTogglePlaylist].forEach({
            $0?.onStateTintFunction = {return Colors.viewControlButtonColor}
            $0?.offStateTintFunction = {return Colors.toggleButtonOffStateColor}
        })
        
        logoImage.tintFunction = {return Colors.appLogoColor}
        
        btnToggleEffects.onIf(persistentState.showEffects)
        btnTogglePlaylist.onIf(persistentState.showPlaylist)
        
        applyColorScheme(ColorSchemes.systemScheme)
        rootContainerBox.cornerRadius = WindowAppearanceState.cornerRadius
        
        // Hackish fix to properly position settings menu button (hamburger icon) on older systems.
        if !SystemUtils.isBigSur {
            
            var frame = btnSettingsMenu.frame
            frame.origin.y += 1
            
            btnSettingsMenu.setFrameOrigin(frame.origin)
        }
    }
    
    // Add the sub-views that make up the main window
    private func addSubViews() {
        containerBox.addSubview(playerView)
    }
    
    private func activateGestureHandler() {
        
        // Register a handler for trackpad/MagicMouse gestures
        gestureHandler = GestureHandler(theWindow)

        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .swipe, .scrollWheel], handler: {[weak self] (event: NSEvent) -> NSEvent? in
            return (self?.gestureHandler.handle(event) ?? false) ? nil : event
        })
    }
    
    private func initSubscriptions() {
        
        Messenger.subscribe(self, .applyTheme, self.applyTheme)
        Messenger.subscribe(self, .applyColorScheme, self.applyColorScheme(_:))
        Messenger.subscribe(self, .changeAppLogoColor, self.changeAppLogoColor(_:))
        Messenger.subscribe(self, .changeBackgroundColor, self.changeBackgroundColor(_:))
        Messenger.subscribe(self, .changeViewControlButtonColor, self.changeViewControlButtonColor(_:))
        Messenger.subscribe(self, .changeToggleButtonOffStateColor, self.changeToggleButtonOffStateColor(_:))

        Messenger.subscribe(self, .windowManager_togglePlaylistWindow, self.togglePlaylistWindow)
        Messenger.subscribe(self, .windowManager_toggleEffectsWindow, self.toggleEffectsWindow)
        
        Messenger.subscribe(self, .windowManager_layoutChanged, self.windowLayoutChanged(_:))
        
        Messenger.subscribe(self, .windowAppearance_changeCornerRadius, self.changeWindowCornerRadius(_:))
    }
    
    func destroy() {
        
        close()
        Messenger.unsubscribeAll(for: self)
    }
    
    // Shows/hides the playlist window (by delegating)
    @IBAction func togglePlaylistAction(_ sender: AnyObject) {
        togglePlaylistWindow()
    }
    
    private func togglePlaylistWindow() {

        WindowManager.instance.togglePlaylist()
        btnTogglePlaylist.toggle()
    }
    
    // Shows/hides the effects panel on the main window
    @IBAction func toggleEffectsAction(_ sender: AnyObject) {
        toggleEffectsWindow()
    }
    
    private func toggleEffectsWindow() {
        
        WindowManager.instance.toggleEffects()
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
    
    @IBAction func statusBarModeAction(_ sender: AnyObject) {
        AppModeManager.presentMode(.statusBar)
    }
    
    private func applyTheme() {
        
        applyColorScheme(ColorSchemes.systemScheme)
        changeWindowCornerRadius(WindowAppearanceState.cornerRadius)
    }
    
    private func applyColorScheme(_ scheme: ColorScheme) {
        
        changeBackgroundColor(scheme.general.backgroundColor)
        changeViewControlButtonColor(scheme.general.viewControlButtonColor)
        changeToggleButtonOffStateColor(scheme.general.toggleButtonOffStateColor)
        changeAppLogoColor(scheme.general.appLogoColor)
    }
    
    private func changeBackgroundColor(_ color: NSColor) {
        rootContainerBox.fillColor = color
    }
    
    private func changeViewControlButtonColor(_ color: NSColor) {
        
        [btnQuit, btnMinimize, btnStatusBarMode, btnTogglePlaylist, btnToggleEffects, settingsMenuIconItem].forEach({
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
        
        btnToggleEffects.onIf(notification.showingEffectsWindow)
        btnTogglePlaylist.onIf(notification.showingPlaylistWindow)
    }
    
    func changeWindowCornerRadius(_ radius: CGFloat) {
        rootContainerBox.cornerRadius = radius
    }
}
