//
//  CompactPlayerWindowController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//

import AppKit

class CompactPlayerWindowController: NSWindowController {
    
    override var windowNibName: NSNib.Name? {"CompactPlayerWindow"}
    
    @IBOutlet weak var rootContainerBox: NSBox!
    
    @IBOutlet weak var logoImage: TintedImageView!
    @IBOutlet weak var btnQuit: TintedImageButton!
    @IBOutlet weak var btnMinimize: TintedImageButton!
    @IBOutlet weak var btnPresentationModeMenu: NSPopUpButton!
    @IBOutlet weak var btnViewMenu: NSPopUpButton!
    
    private var viewPopupMenuContainer: ViewPopupMenuContainer = .init()
    private lazy var settingsMenuIconItem: TintedIconMenuItem = viewPopupMenuContainer.menuIconItem
    
    private lazy var buttonColorChangeReceivers: [ColorSchemePropertyChangeReceiver] = [btnQuit, btnPresentationModeMenu, btnMinimize, settingsMenuIconItem]
    
    @IBOutlet weak var tabView: NSTabView!
    
    let playerViewController: CompactPlayerViewController = .init()
    let playQueueViewController: CompactPlayQueueViewController = .init()
    let searchViewController: CompactPlayQueueSearchViewController = .init()
    let chaptersListViewController: CompactChaptersListViewController = .init()
    let trackInfoViewController: CompactPlayerTrackInfoViewController = .init()
    let lyricsViewController: CompactPlayerLyricsViewController = .init()
    
    lazy var effectsViewLoader: LazyViewLoader<EffectsSheetViewController> = .init()
    private var effectsSheetViewController: EffectsSheetViewController {effectsViewLoader.controller}
    
    lazy var messenger = Messenger(for: self)
    
    private var appMovingWindow: Bool = false
    
    var eventMonitor: EventMonitor! = EventMonitor()
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        initWindow()
        initFromPersistentState()
        
        tabView.tabViewItem(at: 0).view?.addSubview(playerViewController.view)
        tabView.tabViewItem(at: 1).view?.addSubview(playQueueViewController.view)
        tabView.tabViewItem(at: 2).view?.addSubview(searchViewController.view)
        tabView.tabViewItem(at: 3).view?.addSubview(chaptersListViewController.view)
        tabView.tabViewItem(at: 4).view?.addSubview(trackInfoViewController.view)
        tabView.tabViewItem(at: 5).view?.addSubview(lyricsViewController.view)
        
        playQueueViewController.view.anchorToSuperview()
        searchViewController.view.anchorToSuperview()
        chaptersListViewController.view.anchorToSuperview()
        
        tabView.selectTabViewItem(at: 0)
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.captionTextColor, changeReceiver: logoImage)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, changeReceiver: rootContainerBox)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.buttonColor, changeReceivers: buttonColorChangeReceivers)
        
        messenger.subscribe(to: .Effects.sheetDismissed, handler: effectsSheetDismissed)
        
        messenger.subscribe(to: .View.CompactPlayer.showPlayer, handler: showPlayer)
        
        messenger.subscribe(to: .View.togglePlayQueue, handler: showPlayQueue)
        messenger.subscribe(to: .PlayQueue.search, handler: showSearch)
        
        messenger.subscribe(to: .View.toggleEffects, handler: toggleEffects)
        messenger.subscribe(to: .View.toggleChaptersList, handler: showChaptersList)
        
        messenger.subscribe(to: .View.toggleTrackInfo, handler: showTrackInfo)
        messenger.subscribe(to: .Player.trackInfo, handler: showTrackInfo)
        
        messenger.subscribe(to: .View.toggleLyrics, handler: showLyrics)
        
//        messenger.subscribe(to: .View.toggleVisualizer, handler: toggleVisualizer)
        messenger.subscribe(to: .View.changeWindowCornerRadius, handler: changeWindowCornerRadius(to:))
        
        messenger.subscribe(to: .PlayQueue.showPlayingTrack, handler: showPlayingTrackInPlayQueue)
        
        messenger.subscribe(to: .Application.willExit, handler: transferViewState)
        
        setUpEventHandling()
        updateMainMenuState()
    }
    
    private func initWindow() {
        
        window?.isMovableByWindowBackground = true
        
        viewPopupMenuContainer.forceLoadingOfView()
        btnViewMenu.menu?.importItems(from: viewPopupMenuContainer.popupMenu)
    }
    
    private func initFromPersistentState() {
        
        compactPlayerUIState.displayedView = .player
        
        if let rememberedLocation = compactPlayerUIState.windowLocation {
            window?.moveTo(rememberedLocation)
        }
        
        changeWindowCornerRadius(to: playerUIState.cornerRadius)
    }
    
    override func destroy() {
        
        close()
        
        [playerViewController, playQueueViewController, searchViewController,
         chaptersListViewController, trackInfoViewController].forEach {
            
            $0.destroy()
        }
        
        effectsViewLoader.destroy()
        
        eventMonitor.stopMonitoring()
        eventMonitor = nil
        
        messenger.unsubscribeFromAll()
        
        [appDelegate.playbackMenuRootItem, appDelegate.soundMenuRootItem, appDelegate.playQueueMenuRootItem].forEach {
            $0?.enable()
        }
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
        
        defer {updateMainMenuState()}
        
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
    
    func showChaptersList() {
        tabView.selectTabViewItem(at: 3)
    }
    
    func showTrackInfo() {
        tabView.selectTabViewItem(at: 4)
    }
    
    private func showLyrics() {
        tabView.selectTabViewItem(at: 5)
    }
    
    func showPlayingTrackInPlayQueue() {
        showPlayQueue()
    }
    
    func changeWindowCornerRadius(to radius: CGFloat) {
        rootContainerBox.cornerRadius = playerUIState.cornerRadius
    }
    
    private func effectsSheetDismissed() {
        updateDisplayedTabState()
    }
    
    private func transferViewState() {
        compactPlayerUIState.windowLocation = theWindow.frame.origin
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
            compactPlayerUIState.displayedView = .chaptersList
            
        case 4:
            compactPlayerUIState.displayedView = .trackInfo
            
        case 5:
            compactPlayerUIState.displayedView = .lyrics
            
        default:
            return
        }
        
        if compactPlayerUIState.displayedView.equalsOneOf(.player, .playQueue) {
            eventMonitor.resumeMonitoring()
        } else {
            eventMonitor.pauseMonitoring()
        }
        
        updateMainMenuState()
    }
    
    private func updateMainMenuState() {
        
//        appDelegate.playbackMenuRootItem.enableIf(compactPlayerUIState.displayedView == .player)
        appDelegate.soundMenuRootItem.enableIf(compactPlayerUIState.displayedView.equalsOneOf(.player, .effects))
        appDelegate.playQueueMenuRootItem.enableIf(compactPlayerUIState.displayedView == .playQueue)
    }
}

extension CompactPlayerWindowController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        
        rootContainerBox.fillColor = systemColorScheme.backgroundColor
        logoImage.contentTintColor = systemColorScheme.captionTextColor
        
        buttonColorChangeReceivers.forEach {
            $0.colorChanged(systemColorScheme.buttonColor)
        }
    }
}

extension CompactPlayerWindowController: NSTabViewDelegate {
    
    func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        updateDisplayedTabState()
    }
}
