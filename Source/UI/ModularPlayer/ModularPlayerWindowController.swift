//
//  ModularPlayerWindowController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Window controller for the main application window.
 */
class ModularPlayerWindowController: NSWindowController {
    
    override var windowNibName: NSNib.Name? {"ModularPlayerWindow"}
    
    @IBOutlet weak var logoImage: TintedImageView!
    
    // The box that encloses the Now Playing info section
    @IBOutlet weak var rootContainerBox: NSBox!
    @IBOutlet weak var containerBox: NSBox!
    
    private let playerViewController: ModularPlayerViewController = ModularPlayerViewController()
    
    @IBOutlet weak var btnQuit: TintedImageButton!
    @IBOutlet weak var btnMinimize: TintedImageButton!
    
    @IBOutlet weak var btnPresentationModeMenu: NSPopUpButton!
    @IBOutlet weak var btnViewMenu: NSPopUpButton!
    
    private var viewPopupMenuContainer: ViewPopupMenuContainer = .init()
    private lazy var settingsMenuIconItem: TintedIconMenuItem = viewPopupMenuContainer.menuIconItem
    
    var eventMonitor: EventMonitor! = EventMonitor()
    
    let controlsPreferences: GesturesControlsPreferences = preferences.controlsPreferences.gestures
    
    lazy var buttonColorChangeReceivers: [ColorSchemePropertyChangeReceiver] = [btnQuit, btnPresentationModeMenu, btnMinimize, settingsMenuIconItem]
    
    lazy var messenger = Messenger(for: self)
    
    // MARK: Setup
    
    // One-time setup
    override func windowDidLoad() {
        
        theWindow.isMovableByWindowBackground = true
        
        // TODO: Clean this up
        theWindow.setIsVisible(false)
        initWindow()
        theWindow.setIsVisible(false)
        
        setUpEventHandling()
        initSubscriptions()
        
        super.windowDidLoad()
        theWindow.delegate = self
    }
    
    // Set window properties
    private func initWindow() {
        
        theWindow.makeKeyAndOrderFront(self)
        
        containerBox.addSubview(playerViewController.view)
        playerViewController.view.anchorToSuperview()
        
        changeWindowCornerRadius(to: playerUIState.cornerRadius)
        
        viewPopupMenuContainer.forceLoadingOfView()
        btnViewMenu.menu?.importItems(from: viewPopupMenuContainer.popupMenu)
    }
    
    private func initSubscriptions() {
        
        messenger.subscribe(to: .View.togglePlayQueue, handler: togglePlayQueue)
        messenger.subscribe(to: .View.toggleEffects, handler: toggleEffects)
        messenger.subscribe(to: .View.toggleChaptersList, handler: toggleChaptersList)
        messenger.subscribe(to: .View.toggleVisualizer, handler: toggleVisualizer)
        messenger.subscribe(to: .View.toggleWaveform, handler: toggleWaveform)
        messenger.subscribe(to: .View.changeWindowCornerRadius, handler: changeWindowCornerRadius(to:))
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.captionTextColor, changeReceiver: logoImage)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, changeReceiver: rootContainerBox)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.buttonColor, changeReceivers: buttonColorChangeReceivers)
    }
    
    override func destroy() {
        
        close()
        
        eventMonitor?.stopMonitoring()
        eventMonitor = nil
        
        playerViewController.destroy()
        messenger.unsubscribeFromAll()
        
        SingletonPopoverViewController.destroy()
        StringInputPopoverViewController.destroy()
        SingletonWindowController.destroy()
    }
    
    // MARK: Actions -----------------------------------------------------------
    
    // Quits the app
    @IBAction func quitAction(_ sender: AnyObject) {
        NSApp.terminate(self)
    }
    
    // Minimizes the window (and any child windows)
    @IBAction func minimizeAction(_ sender: AnyObject) {
        theWindow.miniaturize(self)
    }
    
    // MARK: Message handling -----------------------------------------------------------
    
    private func togglePlayQueue() {
        
        windowLayoutsManager.toggleWindow(withId: .playQueue)
        appDelegate.playQueueMenuRootItem.enableIf(windowLayoutsManager.isShowingPlayQueue)
    }
    
    private func toggleEffects() {
        windowLayoutsManager.toggleWindow(withId: .effects)
    }
    
    private func toggleChaptersList() {
        windowLayoutsManager.toggleWindow(withId: .chaptersList)
    }
    
    private func toggleVisualizer() {
        windowLayoutsManager.toggleWindow(withId: .visualizer)
    }
    
    private func toggleWaveform() {
        windowLayoutsManager.toggleWindow(withId: .waveform)
    }
    
    func changeWindowCornerRadius(to radius: CGFloat) {
        rootContainerBox.cornerRadius = radius.clamped(to: 0...20)
    }
}

extension ModularPlayerWindowController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        
        logoImage.contentTintColor = systemColorScheme.captionTextColor
        rootContainerBox.fillColor = systemColorScheme.backgroundColor
        
        buttonColorChangeReceivers.forEach {
            $0.colorChanged(systemColorScheme.buttonColor)
        }
    }
}

extension ModularPlayerWindowController: NSWindowDelegate {
    
    func windowDidResize(_ notification: Notification) {
        playerViewController.windowResized()
    }
    
    func windowDidMove(_ notification: Notification) {
        
        let sep = NSScreen.screensHaveSeparateSpaces
        print("Moved: \(theWindow.screen), sep: \(sep)")
        
        for (index, screen) in NSScreen.screens.enumerated() {
            
            print("Screen \(index + 1): \(screen.frame)")
        }
    }
}
