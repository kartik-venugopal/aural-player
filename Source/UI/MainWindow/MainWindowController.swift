import Cocoa

/*
    Window controller for the main application window.
 */
class MainWindowController: NSWindowController, NotificationSubscriber, Destroyable {
    
    // Main application window. Contains the Now Playing info box and player controls. Not resizable.
    private var theWindow: SnappingWindow {
        return self.window! as! SnappingWindow
    }
    
    @IBOutlet weak var logoImage: TintedImageView!
    
    // The box that encloses the Now Playing info section
    @IBOutlet weak var rootContainerBox: NSBox!
    @IBOutlet weak var containerBox: NSBox!
    
    private let playerViewController: PlayerViewController = PlayerViewController()
    
    @IBOutlet weak var btnQuit: TintedImageButton!
    @IBOutlet weak var btnMinimize: TintedImageButton!
    @IBOutlet weak var btnMenuBarMode: TintedImageButton!
    
    // Buttons to toggle the playlist/effects views
    @IBOutlet weak var btnToggleEffects: OnOffImageButton!
    @IBOutlet weak var btnTogglePlaylist: OnOffImageButton!
    @IBOutlet weak var btnSettingsMenu: NSPopUpButton!
    
    @IBOutlet weak var settingsMenuIconItem: TintedIconMenuItem!
    
    @IBOutlet weak var mainMenu: NSMenu!
    
    private var eventMonitor: Any?
    
    private var gestureHandler: GestureHandler!
    
    override var windowNibName: String? {"MainWindow"}
    
    // MARK: Setup
    
    override func awakeFromNib() {
        NSApp.mainMenu = self.mainMenu
    }
    
    // One-time setup
    override func windowDidLoad() {
        
        theWindow.setIsVisible(false)
        initWindow()
        theWindow.setIsVisible(false)
        
        activateGestureHandler()
        initSubscriptions()
        
        super.windowDidLoad()
    }
    
    // Set window properties
    private func initWindow() {
        
        theWindow.isMovableByWindowBackground = true
        theWindow.makeKeyAndOrderFront(self)
        
        containerBox.addSubview(playerViewController.view)
        
        [btnQuit, btnMinimize, btnMenuBarMode].forEach({$0?.tintFunction = {return Colors.viewControlButtonColor}})
        
        [btnToggleEffects, btnTogglePlaylist].forEach({
            $0?.onStateTintFunction = {return Colors.viewControlButtonColor}
            $0?.offStateTintFunction = {return Colors.toggleButtonOffStateColor}
        })
        
        logoImage.tintFunction = {return Colors.appLogoColor}
        
        btnToggleEffects.onIf(WindowLayoutState.showEffects)
        btnTogglePlaylist.onIf(WindowLayoutState.showPlaylist)
        
        applyColorScheme(ColorSchemes.systemScheme)
        rootContainerBox.cornerRadius = WindowAppearanceState.cornerRadius
        
        // Hackish fix to properly position settings menu button (hamburger icon) on older systems.
        if !SystemUtils.isBigSur {
            
            var frame = btnSettingsMenu.frame
            frame.origin.y += 1
            
            btnSettingsMenu.setFrameOrigin(frame.origin)
        }
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
        
        playerViewController.destroy()
        
        close()
        Messenger.unsubscribeAll(for: self)
        
        InfoPopupViewController.destroy()
        AlertWindowController.destroy()
        EditorWindowController.destroy()
        
        NSApp.mainMenu = nil
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
    
    @IBAction func menuBarModeAction(_ sender: AnyObject) {
        AppModeManager.presentMode(.menuBar)
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
        
        [btnQuit, btnMinimize, btnMenuBarMode, btnTogglePlaylist, btnToggleEffects, settingsMenuIconItem].forEach({
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
