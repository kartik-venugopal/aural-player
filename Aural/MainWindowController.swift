import Cocoa

/*
    Window controller for the main window, but also controls the positioning and sizing of the playlist window. Performs any and all display (or hiding), positioning, alignment, resizing, etc. of both the main window and playlist window.
 */
class MainWindowController: NSWindowController, NSWindowDelegate, NSMenuDelegate, MessageSubscriber, ActionMessageSubscriber, ConstituentView {
    
    // Main application window. Contains the Now Playing info box, player controls, and effects panel. Not manually resizable. Changes size when toggling effects view.
    private var theWindow: SnappingWindow {
        return self.window! as! SnappingWindow
    }
    
    @IBOutlet weak var btnClose: ColorSensitiveImageButton! {
        
        didSet {
            btnClose.imageMappings[.darkBackground_lightText] = NSImage(named: "Close")
            btnClose.imageMappings[.lightBackground_darkText] = NSImage(named: "Close_1")
        }
    }
    
    @IBOutlet weak var btnHide: ColorSensitiveImageButton! {
        
        didSet {
            btnHide.imageMappings[.darkBackground_lightText] = NSImage(named: "Hide")
            btnHide.imageMappings[.lightBackground_darkText] = NSImage(named: "Hide_1")
        }
    }
    
    @IBOutlet weak var rootContainer: NSBox!
    
    // The box that encloses the Now Playing info section
    @IBOutlet weak var containerBox: NSBox!
    private lazy var playerView: NSView = ViewFactory.getPlayerView()
    
    @IBOutlet weak var imgAppTitle: ColorSensitiveImage! {
        
        didSet {
            imgAppTitle.imageMappings[.darkBackground_lightText] = NSImage(named: "AppTitle")
            imgAppTitle.imageMappings[.lightBackground_darkText] = NSImage(named: "AppTitle_1")
        }
    }
    
    // Buttons to toggle the playlist/effects views
    @IBOutlet weak var btnToggleEffects: ColorSensitiveOnOffImageButton! {
        
        didSet {
            btnToggleEffects.offStateImageMappings[.darkBackground_lightText] = NSImage(named: "EffectsView-Off")!
            btnToggleEffects.offStateImageMappings[.lightBackground_darkText] = NSImage(named: "EffectsView-Off_1")!
            
            btnToggleEffects.onStateImageMappings[.darkBackground_lightText] = NSImage(named: "EffectsView-On")!
            btnToggleEffects.onStateImageMappings[.lightBackground_darkText] = NSImage(named: "EffectsView-On_1")!
        }
    }
    
    @IBOutlet weak var btnTogglePlaylist: ColorSensitiveOnOffImageButton! {
        
        didSet {
            btnTogglePlaylist.offStateImageMappings[.darkBackground_lightText] = NSImage(named: "PlaylistView-Off")!
            btnTogglePlaylist.offStateImageMappings[.lightBackground_darkText] = NSImage(named: "PlaylistView-Off_1")!
            
            btnTogglePlaylist.onStateImageMappings[.darkBackground_lightText] = NSImage(named: "PlaylistView-On")!
            btnTogglePlaylist.onStateImageMappings[.lightBackground_darkText] = NSImage(named: "PlaylistView-On_1")!
        }
    }
    
    @IBOutlet weak var btnLayout: NSPopUpButton!
    @IBOutlet weak var layoutMenuImageItem: ColorSensitiveMenuItem! {
        
        didSet {
            layoutMenuImageItem.imageMappings[.darkBackground_lightText] = NSImage(named: "WindowLayout-Light")
            layoutMenuImageItem.imageMappings[.lightBackground_darkText] = NSImage(named: "WindowLayout-Light_1")
        }
    }
    
    @IBOutlet weak var viewMenuButton: NSPopUpButton!
    @IBOutlet weak var viewMenuImageItem: ColorSensitiveMenuItem! {
        
        didSet {
            viewMenuImageItem.imageMappings[.darkBackground_lightText] = NSImage(named: "Settings")
            viewMenuImageItem.imageMappings[.lightBackground_darkText] = NSImage(named: "Settings_1")
        }
    }
    
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
        
        changeTextSize()
        changeColorScheme()
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
        SyncMessenger.subscribe(actionTypes: [.toggleEffects, .togglePlaylist, .changePlayerTextSize, .changeColorScheme], subscriber: self)
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
    
    @IBAction func floatingBarModeAction(_ sender: AnyObject) {
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
    
    private func changeColorScheme() {
        
        imgAppTitle.colorSchemeChanged()
        rootContainer.fillColor = Colors.windowBackgroundColor
        
        [btnClose, btnHide].forEach({$0.colorSchemeChanged()})
        [layoutMenuImageItem, viewMenuImageItem].forEach({$0.colorSchemeChanged()})
        [btnToggleEffects, btnTogglePlaylist].forEach({$0.colorSchemeChanged()})
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
            
        case .changeColorScheme:    changeColorScheme()
            
        default: return
            
        }
    }
    
    var subscriberId: String {
        return self.className
    }
}

class PlayerViewPopupMenuController: NSObject, NSMenuDelegate {
    
    @IBOutlet weak var playerDefaultViewMenuItem: NSMenuItem!
    @IBOutlet weak var playerExpandedArtViewMenuItem: NSMenuItem!
    
    @IBOutlet weak var showArtMenuItem: NSMenuItem!
    @IBOutlet weak var showTrackInfoMenuItem: NSMenuItem!
//    @IBOutlet weak var showSequenceInfoMenuItem: NSMenuItem!
    @IBOutlet weak var showTrackFunctionsMenuItem: NSMenuItem!
    @IBOutlet weak var showMainControlsMenuItem: NSMenuItem!
    @IBOutlet weak var showTimeElapsedRemainingMenuItem: NSMenuItem!
    
    @IBOutlet weak var timeElapsedFormatMenuItem: NSMenuItem!
    @IBOutlet weak var timeElapsedMenuItem_hms: NSMenuItem!
    @IBOutlet weak var timeElapsedMenuItem_seconds: NSMenuItem!
    @IBOutlet weak var timeElapsedMenuItem_percentage: NSMenuItem!
    private var timeElapsedDisplayFormats: [NSMenuItem] = []
    
    @IBOutlet weak var timeRemainingFormatMenuItem: NSMenuItem!
    @IBOutlet weak var timeRemainingMenuItem_hms: NSMenuItem!
    @IBOutlet weak var timeRemainingMenuItem_seconds: NSMenuItem!
    @IBOutlet weak var timeRemainingMenuItem_percentage: NSMenuItem!
    @IBOutlet weak var timeRemainingMenuItem_durationHMS: NSMenuItem!
    @IBOutlet weak var timeRemainingMenuItem_durationSeconds: NSMenuItem!
    private var timeRemainingDisplayFormats: [NSMenuItem] = []
    
    @IBOutlet weak var textSizeNormalMenuItem: NSMenuItem!
    @IBOutlet weak var textSizeLargerMenuItem: NSMenuItem!
    @IBOutlet weak var textSizeLargestMenuItem: NSMenuItem!
    private var textSizes: [NSMenuItem] = []
    
    private let viewAppState = ObjectGraph.appState.ui.player
    
    private let player: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    override func awakeFromNib() {
        
        timeElapsedDisplayFormats = [timeElapsedMenuItem_hms, timeElapsedMenuItem_seconds, timeElapsedMenuItem_percentage]
        timeRemainingDisplayFormats = [timeRemainingMenuItem_hms, timeRemainingMenuItem_seconds, timeRemainingMenuItem_percentage, timeRemainingMenuItem_durationHMS, timeRemainingMenuItem_durationSeconds]
        textSizes = [textSizeNormalMenuItem, textSizeLargerMenuItem, textSizeLargestMenuItem]
    }
    
    // When the menu is about to open, set the menu item states according to the current window/view state
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        // Can't change the player view while transcoding
        for index in 2..<menu.items.count {
            menu.items[index].disableIf(player.state == .transcoding)
        }
        
        // Player view:
        playerDefaultViewMenuItem.onIf(PlayerViewState.viewType == .defaultView)
        playerExpandedArtViewMenuItem.onIf(PlayerViewState.viewType == .expandedArt)
        
        [showArtMenuItem, showMainControlsMenuItem].forEach({$0.hideIf_elseShow(PlayerViewState.viewType == .expandedArt)})
        
        showTrackInfoMenuItem.hideIf_elseShow(PlayerViewState.viewType == .defaultView)
//        showSequenceInfoMenuItem.showIf_elseHide(PlayerViewState.viewType == .defaultView || PlayerViewState.showTrackInfo)
        
        let defaultViewAndShowingControls = PlayerViewState.viewType == .defaultView && PlayerViewState.showControls
        showTimeElapsedRemainingMenuItem.showIf_elseHide(defaultViewAndShowingControls)
        
        showArtMenuItem.onIf(PlayerViewState.showAlbumArt)
        showTrackInfoMenuItem.onIf(PlayerViewState.showTrackInfo)
//        showSequenceInfoMenuItem.onIf(PlayerViewState.showSequenceInfo)
        showTrackFunctionsMenuItem.onIf(PlayerViewState.showPlayingTrackFunctions)
        
        showMainControlsMenuItem.onIf(PlayerViewState.showControls)
        showTimeElapsedRemainingMenuItem.onIf(PlayerViewState.showTimeElapsedRemaining)
        
        timeElapsedFormatMenuItem.showIf_elseHide(defaultViewAndShowingControls)
        timeRemainingFormatMenuItem.showIf_elseHide(defaultViewAndShowingControls)
        
        if defaultViewAndShowingControls {
            
            timeElapsedDisplayFormats.forEach({$0.off()})
            
            switch PlayerViewState.timeElapsedDisplayType {
                
            case .formatted:    timeElapsedMenuItem_hms.on()
                
            case .seconds:      timeElapsedMenuItem_seconds.on()
                
            case .percentage:   timeElapsedMenuItem_percentage.on()
                
            }
            
            timeRemainingDisplayFormats.forEach({$0.off()})
            
            switch PlayerViewState.timeRemainingDisplayType {
                
            case .formatted:    timeRemainingMenuItem_hms.on()
                
            case .seconds:      timeRemainingMenuItem_seconds.on()
                
            case .percentage:   timeRemainingMenuItem_percentage.on()
                
            case .duration_formatted:   timeRemainingMenuItem_durationHMS.on()
                
            case .duration_seconds:     timeRemainingMenuItem_durationSeconds.on()
                
            }
        }
        
        textSizes.forEach({
            $0.off()
        })
        
        switch PlayerViewState.textSize {
            
        case .normal:   textSizeNormalMenuItem.on()
            
        case .larger:   textSizeLargerMenuItem.on()
            
        case .largest:  textSizeLargestMenuItem.on()
            
        }
    }
    
    @IBAction func playerDefaultViewAction(_ sender: NSMenuItem) {
        SyncMessenger.publishActionMessage(PlayerViewActionMessage(.defaultView))
    }
    
    @IBAction func playerExpandedArtViewAction(_ sender: NSMenuItem) {
        SyncMessenger.publishActionMessage(PlayerViewActionMessage(.expandedArt))
    }
    
    @IBAction func showOrHidePlayingTrackFunctionsAction(_ sender: NSMenuItem) {
        SyncMessenger.publishActionMessage(ViewActionMessage(.showOrHidePlayingTrackFunctions))
    }
    
    @IBAction func showOrHidePlayingTrackInfoAction(_ sender: NSMenuItem) {
        SyncMessenger.publishActionMessage(ViewActionMessage(.showOrHidePlayingTrackInfo))
    }
    
//    @IBAction func showOrHideSequenceInfoAction(_ sender: NSMenuItem) {
//        SyncMessenger.publishActionMessage(ViewActionMessage(.showOrHideSequenceInfo))
//    }
    
    @IBAction func showOrHideAlbumArtAction(_ sender: NSMenuItem) {
        SyncMessenger.publishActionMessage(ViewActionMessage(.showOrHideAlbumArt))
    }
    
    @IBAction func showOrHideMainControlsAction(_ sender: NSMenuItem) {
        SyncMessenger.publishActionMessage(ViewActionMessage(.showOrHideMainControls))
    }
    
    @IBAction func showOrHideTimeElapsedRemainingAction(_ sender: NSMenuItem) {
        SyncMessenger.publishActionMessage(ViewActionMessage(.showOrHideTimeElapsedRemaining))
    }
    
    @IBAction func changeTextSizeAction(_ sender: NSMenuItem) {
        
        let senderTitle: String = sender.title.lowercased()
        let size = TextSizeScheme(rawValue: senderTitle)!
        
        if TextSizes.playerScheme != size {
            
            TextSizes.playerScheme = size
            SyncMessenger.publishActionMessage(TextSizeActionMessage(.changePlayerTextSize, size))
        }
    }
    
    @IBAction func timeElapsedDisplayFormatAction(_ sender: NSMenuItem) {
        
        var format: TimeElapsedDisplayType
        
        switch sender.tag {
            
        case 0: format = .formatted
            
        case 1: format = .seconds
            
        case 2: format = .percentage
            
        default: format = .formatted
            
        }
        
        SyncMessenger.publishActionMessage(SetTimeElapsedDisplayFormatActionMessage(format))
    }
    
    @IBAction func timeRemainingDisplayFormatAction(_ sender: NSMenuItem) {
        
        var format: TimeRemainingDisplayType
        
        switch sender.tag {
            
        case 0: format = .formatted
            
        case 1: format = .seconds
            
        case 2: format = .percentage
            
        case 3: format = .duration_formatted
            
        case 4: format = .duration_seconds
            
        default: format = .formatted
            
        }
        
        SyncMessenger.publishActionMessage(SetTimeRemainingDisplayFormatActionMessage(format))
    }
}
