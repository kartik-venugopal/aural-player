//
//  MainWindowController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Window controller for the main application window.
 */
class MainWindowController: NSWindowController, Destroyable {
    
    @IBOutlet weak var logoImage: TintedImageView!
    
    // The box that encloses the Now Playing info section
    @IBOutlet weak var rootContainerBox: NSBox!
    @IBOutlet weak var containerBox: NSBox!
    
    private let playerViewController: PlayerViewController = PlayerViewController()
    
    @IBOutlet weak var btnQuit: TintedImageButton!
    @IBOutlet weak var btnMinimize: TintedImageButton!
    @IBOutlet weak var btnMenuBarMode: TintedImageButton!
    @IBOutlet weak var btnControlBarMode: TintedImageButton!
    
    // Buttons to toggle the playlist/effects views
    @IBOutlet weak var btnToggleEffects: OnOffImageButton!
    @IBOutlet weak var btnTogglePlaylist: OnOffImageButton!
    @IBOutlet weak var btnSettingsMenu: NSPopUpButton!
    
    @IBOutlet weak var settingsMenuIconItem: TintedIconMenuItem!
    
    @IBOutlet weak var mainMenu: NSMenu!
    
    private var eventMonitor: EventMonitor! = EventMonitor()
    
    // Delegate that retrieves current playback info
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    private let preferences: GesturesControlsPreferences = ObjectGraph.preferences.controlsPreferences.gestures
    
    private let colorSchemesManager: ColorSchemesManager = ObjectGraph.colorSchemesManager
    
    override var windowNibName: String? {"MainWindow"}
    
    private lazy var messenger = Messenger(for: self)
    
    // MARK: Setup
    
    override func awakeFromNib() {
        NSApp.mainMenu = self.mainMenu
    }
    
    // One-time setup
    override func windowDidLoad() {
        
        // TODO: Clean this up
        theWindow.setIsVisible(false)
        initWindow()
        theWindow.setIsVisible(false)
        
        setUpEventHandling()
        initSubscriptions()
        
        super.windowDidLoad()
    }
    
    // Set window properties
    private func initWindow() {
        
        theWindow.isMovableByWindowBackground = true
        theWindow.makeKeyAndOrderFront(self)
        
        containerBox.addSubview(playerViewController.view)
        
        [btnQuit, btnMinimize, btnMenuBarMode, btnControlBarMode].forEach {$0?.tintFunction = {Colors.viewControlButtonColor}}
        
        [btnToggleEffects, btnTogglePlaylist].forEach {
            
            $0?.onStateTintFunction = {Colors.viewControlButtonColor}
            $0?.offStateTintFunction = {Colors.toggleButtonOffStateColor}
        }
        
        logoImage.tintFunction = {Colors.appLogoColor}
        
        btnToggleEffects.onIf(WindowLayoutState.showEffects)
        btnTogglePlaylist.onIf(WindowLayoutState.showPlaylist)
        
        applyColorScheme(colorSchemesManager.systemScheme)
        rootContainerBox.cornerRadius = WindowAppearanceState.cornerRadius
        
        // Hackish fix to properly position settings menu button (hamburger icon) on older systems.
        if !SystemUtils.isBigSur {
            btnSettingsMenu.moveUp(distance: 1)
        }
    }
    
    // Registers handlers for keyboard events and trackpad/mouse gestures (NSEvent).
    private func setUpEventHandling() {
        
        eventMonitor.registerHandler(forEventType: .keyDown, self.handleKeyDown(_:))
        eventMonitor.registerHandler(forEventType: .scrollWheel, self.handleScroll(_:))
        eventMonitor.registerHandler(forEventType: .swipe, self.handleSwipe(_:))

        eventMonitor.startMonitoring()
    }
    
    private func initSubscriptions() {
        
        messenger.subscribe(to: .applyTheme, handler: applyTheme)
        messenger.subscribe(to: .applyColorScheme, handler: applyColorScheme(_:))
        messenger.subscribe(to: .changeAppLogoColor, handler: changeAppLogoColor(_:))
        messenger.subscribe(to: .changeBackgroundColor, handler: changeBackgroundColor(_:))
        messenger.subscribe(to: .changeViewControlButtonColor, handler: changeViewControlButtonColor(_:))
        messenger.subscribe(to: .changeToggleButtonOffStateColor, handler: changeToggleButtonOffStateColor(_:))

        messenger.subscribe(to: .windowManager_togglePlaylistWindow, handler: togglePlaylistWindow)
        messenger.subscribe(to: .windowManager_toggleEffectsWindow, handler: toggleEffectsWindow)
        
        messenger.subscribe(to: .windowManager_layoutChanged, handler: windowLayoutChanged(_:))
        
        messenger.subscribe(to: .windowAppearance_changeCornerRadius, handler: changeWindowCornerRadius(_:))
    }
    
    func destroy() {
        
        eventMonitor.stopMonitoring()
        eventMonitor = nil
        
        playerViewController.destroy()
        
        close()
        messenger.unsubscribeFromAll()
        
        InfoPopupViewController.destroy()
        AlertWindowController.destroy()
        PresetsManagerWindowController.destroy()
        
        mainMenu.items.forEach {$0.hide()}
        
        if let auralMenu = mainMenu.item(withTitle: "Aural") {
            
            auralMenu.menu?.items.forEach {$0.disable()}
            auralMenu.show()
        }
        
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
        messenger.publish(.application_switchMode, payload: AppMode.menuBar)
    }
    
    @IBAction func controlBarModeAction(_ sender: AnyObject) {
        messenger.publish(.application_switchMode, payload: AppMode.controlBar)
    }
    
    private func applyTheme() {
        
        applyColorScheme(colorSchemesManager.systemScheme)
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
        
        [btnQuit, btnMinimize, btnMenuBarMode, btnControlBarMode,
         btnTogglePlaylist, btnToggleEffects, settingsMenuIconItem].forEach {
            
            ($0 as? Tintable)?.reTint()
        }
    }
    
    private func changeToggleButtonOffStateColor(_ color: NSColor) {
        
        // These are the only 2 buttons that have off states
        [btnTogglePlaylist, btnToggleEffects].forEach {
            $0.reTint()
        }
    }
    
    private func changeAppLogoColor(_ color: NSColor) {
        logoImage.reTint()
    }
    
    // MARK: Message handling -----------------------------------------------------------
    
    func windowLayoutChanged(_ notification: WindowLayoutChangedNotification) {
        
        btnToggleEffects.onIf(notification.showingEffectsWindow)
        btnTogglePlaylist.onIf(notification.showingPlaylistWindow)
    }
    
    func changeWindowCornerRadius(_ radius: CGFloat) {
        rootContainerBox.cornerRadius = radius
    }
    
    // MARK: Event handling (keyboard and gestures) ---------------------------------------
    
    // Handles a single key press event. Returns nil if the event has been successfully handled (or needs to be suppressed),
    // returns the same event otherwise.
    private func handleKeyDown(_ event: NSEvent) -> NSEvent? {

        // One-off special case: Without this, a space key press (for play/pause) is not sent to main window
        // Send the space key event to the main window unless a modal component is currently displayed
        if event.charactersIgnoringModifiers == " " && !WindowManager.instance.isShowingModalComponent {

            self.window?.keyDown(with: event)
            return nil
        }

        return event
    }

    // Handles a single swipe event
    private func handleSwipe(_ event: NSEvent) -> NSEvent? {

        // If a modal dialog is open, don't do anything
        // Also, ignore any gestures that weren't triggered over the main window (they trigger other functions if performed over the playlist window)

        if event.window === self.window,
           !WindowManager.instance.isShowingModalComponent,
           let swipeDirection = event.gestureDirection, swipeDirection.isHorizontal {

            handleTrackChange(swipeDirection)
        }

        return event
    }

    // Handles a single scroll event
    private func handleScroll(_ event: NSEvent) -> NSEvent? {

        // If a modal dialog is open, don't do anything
        // Also, ignore any gestures that weren't triggered over the main window (they trigger other functions if performed over the playlist window)

        // Calculate the direction and magnitude of the scroll (nil if there is no direction information)
        if event.window === self.window,
           !WindowManager.instance.isShowingModalComponent,
           let scrollDirection = event.gestureDirection {

            // Vertical scroll = volume control, horizontal scroll = seeking
            scrollDirection.isVertical ? handleVolumeControl(event, scrollDirection) : handleSeek(event, scrollDirection)
        }

        return event
    }
    
    private func handleTrackChange(_ swipeDirection: GestureDirection) {
        
        if preferences.allowTrackChange {
            
            // Publish the command notification
            messenger.publish(swipeDirection == .left ? .player_previousTrack : .player_nextTrack)
        }
    }
    
    private func handleVolumeControl(_ event: NSEvent, _ scrollDirection: GestureDirection) {
        
        if preferences.allowVolumeControl && ScrollSession.validateEvent(timestamp: event.timestamp, eventDirection: scrollDirection) {
        
            // Scroll up = increase volume, scroll down = decrease volume
            messenger.publish(scrollDirection == .up ?.player_increaseVolume : .player_decreaseVolume, payload: UserInputMode.continuous)
        }
    }
    
    private func handleSeek(_ event: NSEvent, _ scrollDirection: GestureDirection) {
        
        if preferences.allowSeeking {
            
            // If no track is playing, seeking cannot be performed
            if playbackInfo.state.isNotPlayingOrPaused {
                return
            }
            
            // Seeking forward (do not allow residual scroll)
            if scrollDirection == .right && isResidualScroll(event) {
                return
            }
            
            if ScrollSession.validateEvent(timestamp: event.timestamp, eventDirection: scrollDirection) {
        
                // Scroll left = seek backward, scroll right = seek forward
                messenger.publish(scrollDirection == .left ? .player_seekBackward : .player_seekForward, payload: UserInputMode.continuous)
            }
        }
    }
    
    /*
        "Residual scrolling" occurs when seeking forward to the end of a playing track (scrolling right), resulting in the next track playing while the scroll is still occurring. Inertia (i.e. the momentum phase of the scroll) can cause scrolling, and hence seeking, to continue after the new track has begun playing. This is undesirable behavior. The scrolling should stop when the new track begins playing.
     
        To prevent residual scrolling, we need to take into account the following variables:
        - the time when the scroll session began
        - the time when the new track began playing
        - the time interval between this event and the last event
     
        Returns a value indicating whether or not this event constitutes residual scroll.
     */
    private func isResidualScroll(_ event: NSEvent) -> Bool {
    
        // If the scroll session began before the currently playing track began playing, then it is now invalid and all its future events should be ignored.
        if let playingTrackStartTime = playbackInfo.playingTrackStartTime,
           let scrollSessionStartTime = ScrollSession.sessionStartTime,
            scrollSessionStartTime < playingTrackStartTime {
        
            // If the time interval between this event and the last one in the scroll session is within the maximum allowed gap between events, it is a part of the previous scroll session
            let lastEventTime = ScrollSession.lastEventTime ?? 0
            
            // If the session is invalid and this event is part of that invalid session, that indicates residual scroll, and the event should not be processed
            if (event.timestamp - lastEventTime) < ScrollSession.maxTimeGapSeconds {
                
                // Mark the timestamp of this event (for future events), but do not process it
                ScrollSession.updateLastEventTime(event)
                return true
            }
        }
        
        // Not residual scroll
        return false
    }
}
