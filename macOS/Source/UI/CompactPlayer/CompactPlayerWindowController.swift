//
//  CompactPlayerWindowController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//

import AppKit

class CompactPlayerWindowController: NSWindowController {
    
    override var windowNibName: NSNib.Name? {"CompactPlayerWindow"}
    
    @IBOutlet weak var mainMenu: NSMenu!
    
    @IBOutlet weak var rootContainerBox: NSBox!
    
    @IBOutlet weak var logoImage: TintedImageView!
    @IBOutlet weak var btnQuit: TintedImageButton!
    @IBOutlet weak var btnMinimize: TintedImageButton!
    @IBOutlet weak var presentationModeMenuItem: TintedIconMenuItem!
    @IBOutlet weak var settingsMenuIconItem: TintedIconMenuItem!
    
    @IBOutlet weak var tabView: NSTabView!
    let playerViewController: CompactPlayerViewController = .init()
    var playQueueViewController: CompactPlayQueueViewController! = .init()
    let searchViewController: CompactPlayQueueSearchViewController = .init()
    lazy var effectsSheetViewController: EffectsSheetViewController = .init()
    lazy var trackInfoViewController: CompactPlayerTrackInfoViewController = .init()
    
    lazy var messenger = Messenger(for: self)
    
    private var appMovingWindow: Bool = false
    
    var eventMonitor: EventMonitor! = EventMonitor()
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        NSApp.mainMenu = self.mainMenu
    }
    
    override func windowDidLoad() {
        
        window?.isMovableByWindowBackground = true
        window?.center()
        
        initFromPersistentState()
        
        tabView.tabViewItem(at: 0).view?.addSubview(playerViewController.view)
        tabView.tabViewItem(at: 1).view?.addSubview(playQueueViewController.view)
        tabView.tabViewItem(at: 2).view?.addSubview(searchViewController.view)
        tabView.tabViewItem(at: 3).view?.addSubview(trackInfoViewController.view)
        
        playQueueViewController.view.anchorToSuperview()
        searchViewController.view.anchorToSuperview()
        
        tabView.selectTabViewItem(at: 0)
        
        colorSchemesManager.registerSchemeObserver(self)
        
        messenger.subscribe(to: .Effects.sheetDismissed, handler: effectsSheetDismissed)
        
        messenger.subscribe(to: .CompactPlayer.showPlayer, handler: showPlayer)
        messenger.subscribe(to: .CompactPlayer.showPlayQueue, handler: showPlayQueue)
        messenger.subscribe(to: .CompactPlayer.toggleEffects, handler: toggleEffects)
        messenger.subscribe(to: .CompactPlayer.showTrackInfo, handler: showTrackInfo)
        messenger.subscribe(to: .CompactPlayer.changeWindowCornerRadius, handler: changeWindowCornerRadius)
        messenger.subscribe(to: .PlayQueue.showPlayingTrack, handler: showPlayingTrackInPlayQueue)
        
        messenger.subscribe(to: .CompactPlayer.switchToModularMode, handler: switchToModularMode)
        messenger.subscribe(to: .CompactPlayer.switchToUnifiedMode, handler: switchToUnifiedMode)
        messenger.subscribe(to: .CompactPlayer.switchToMenuBarMode, handler: switchToMenuBarMode)
        messenger.subscribe(to: .CompactPlayer.switchToWidgetMode, handler: switchToWidgetMode)
        
        messenger.subscribe(to: .CompactPlayer.showSearch, handler: showSearch)
        
        setUpEventHandling()
    }
    
    private func initFromPersistentState() {
        
        compactPlayerUIState.displayedView = .player
        
        if let rememberedLocation = compactPlayerUIState.windowLocation {
            window?.setFrameOrigin(rememberedLocation)
        }
        
        changeWindowCornerRadius()
    }
    
    override func destroy() {
        
        close()
        
        [playerViewController, playQueueViewController, searchViewController].forEach {
            $0.destroy()
        }
        
        playQueueViewController = nil
        
        eventMonitor.stopMonitoring()
        eventMonitor = nil
        
        messenger.unsubscribeFromAll()
        
        NSApp.mainMenu = nil
    }
    
    func showPlayer() {
        
        if compactPlayerUIState.displayedView == .effects {
            effectsSheetViewController.endSheet()
        }
        
        guard compactPlayerUIState.displayedView != .player else {return}
        
        tabView.selectTabViewItem(at: 0)
    }
    
    func showPlayQueue() {
        
        if compactPlayerUIState.displayedView == .effects {
            effectsSheetViewController.endSheet()
        }
        
        guard compactPlayerUIState.displayedView != .playQueue else {return}
        
        tabView.selectTabViewItem(at: 1)
    }
    
    func toggleEffects() {
        
        if compactPlayerUIState.displayedView == .effects {
            
            effectsSheetViewController.endSheet()
            return
        }
        
        // Effects not shown, so show it.
        
        switch compactPlayerUIState.displayedView {
            
        case .player:
            playerViewController.presentAsSheet(effectsSheetViewController)
            
        case .playQueue:
            playQueueViewController.presentAsSheet(effectsSheetViewController)
            
        case .search:
            searchViewController.presentAsSheet(effectsSheetViewController)
            
        case .trackInfo:
            trackInfoViewController.presentAsSheet(effectsSheetViewController)
            
        default:
            return
        }
        
        compactPlayerUIState.displayedView = .effects
        eventMonitor.pauseMonitoring()
    }
    
    func showSearch() {
        tabView.selectTabViewItem(at: 2)
    }
    
    func showTrackInfo() {
        tabView.selectTabViewItem(at: 3)
    }
    
    func showPlayingTrackInPlayQueue() {
        showPlayQueue()
    }
    
    private func transferViewState() {
        compactPlayerUIState.windowLocation = theWindow.frame.origin
    }
    
    func changeWindowCornerRadius() {
        rootContainerBox.cornerRadius = compactPlayerUIState.cornerRadius
    }
    
    private func effectsSheetDismissed() {
        updateDisplayedTabState()
    }
    
    @IBAction func modularModeAction(_ sender: AnyObject) {
        switchToModularMode()
    }
    
    @IBAction func unifiedModeAction(_ sender: AnyObject) {
        switchToUnifiedMode()
    }
    
    @IBAction func menuBarModeAction(_ sender: AnyObject) {
        switchToMenuBarMode()
    }
    
    @IBAction func widgetModeAction(_ sender: AnyObject) {
        switchToWidgetMode()
    }
    
    private func switchToModularMode() {
        
        transferViewState()
        appModeManager.presentMode(.modular)
    }
    
    private func switchToUnifiedMode() {
        
        transferViewState()
        appModeManager.presentMode(.unified)
    }
    
    private func switchToMenuBarMode() {
        
        transferViewState()
        appModeManager.presentMode(.menuBar)
    }
    
    private func switchToWidgetMode() {
        
        transferViewState()
        appModeManager.presentMode(.widget)
    }
    
    // Minimizes the window (and any child windows)
    @IBAction func minimizeAction(_ sender: AnyObject) {
        theWindow.miniaturize(self)
    }
    
    @IBAction func quitAction(_ sender: AnyObject) {
        
        transferViewState()
        NSApp.terminate(self)
    }
    
    private func updateDisplayedTabState() {
        
        // NOTE: Effects does not have its own tab (it's displayed in a separate sheet view).
        
        switch tabView.selectedIndex {
            
        case 0:
            compactPlayerUIState.displayedView = .player
            
        case 1:
            compactPlayerUIState.displayedView = .playQueue
            
        case 2:
            compactPlayerUIState.displayedView = .search
            
        case 3:
            compactPlayerUIState.displayedView = .trackInfo
            
        default:
            return
        }
        
        if compactPlayerUIState.displayedView == .player {
            eventMonitor.resumeMonitoring()
        } else {
            eventMonitor.pauseMonitoring()
        }
    }
}

extension CompactPlayerWindowController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        
        rootContainerBox.fillColor = systemColorScheme.backgroundColor
        logoImage.contentTintColor = systemColorScheme.captionTextColor
        
        [btnQuit, btnMinimize].forEach {
            $0.contentTintColor = systemColorScheme.buttonColor
        }
        
        [presentationModeMenuItem, settingsMenuIconItem].forEach {
            $0?.colorChanged(systemColorScheme.buttonColor)
        }
    }
}

extension CompactPlayerWindowController: NSTabViewDelegate {
    
    func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        updateDisplayedTabState()
    }
}
