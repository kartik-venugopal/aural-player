//
//  UnifiedPlayerWindowController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class UnifiedPlayerWindowController: NSWindowController {
    
    override var windowNibName: NSNib.Name? {"UnifiedPlayerWindow"}
    
    @IBOutlet weak var logoImage: TintedImageView!
    @IBOutlet weak var rootContainerBox: NSBox!
    
    @IBOutlet weak var btnQuit: TintedImageButton!
    @IBOutlet weak var btnMinimize: TintedImageButton!
    @IBOutlet weak var btnToggleSidebar: TintedImageButton!
    @IBOutlet weak var btnPresentationModeMenu: NSPopUpButton!
    @IBOutlet weak var btnViewMenu: NSPopUpButton!
    
    private var viewPopupMenuContainer: ViewPopupMenuContainer = .init()
    private lazy var settingsMenuIconItem: TintedIconMenuItem = viewPopupMenuContainer.menuIconItem
    
    @IBOutlet weak var rootSplitView: NSSplitView!
    @IBOutlet weak var browserSplitView: NSSplitView!
    
    // The tab group that switches between the 4 playlist views
    @IBOutlet weak var tabGroup: NSTabView!
    
    lazy var buttonColorChangeReceivers: [ColorSchemePropertyChangeReceiver] = [btnQuit, btnPresentationModeMenu, btnMinimize, btnToggleSidebar, settingsMenuIconItem]
    
    // MARK: View Controllers ----------------------------------------
    
    let playerViewController: UnifiedPlayerViewController = .init()
    let waveformViewController: UnifiedPlayerWaveformContainerViewController = .init()
    
    private let sidebarController: UnifiedPlayerSidebarViewController = .init()
    private let playQueueController: PlayQueueContainerViewController = .init()
    
    private lazy var effectsViewLoader: LazyViewLoader<EffectsSheetViewController> = .init()
    var effectsSheetViewController: EffectsSheetViewController {effectsViewLoader.controller}
    
    private lazy var lyricsViewLoader: LazyViewLoader<LyricsSheetViewController> = .init()
    var lyricsSheetViewController: LyricsSheetViewController {lyricsViewLoader.controller}
    
    private lazy var chaptersListViewLoader: LazyViewLoader<ChaptersListViewController> = .init()
    private var chaptersListController: ChaptersListViewController {chaptersListViewLoader.controller}
    
//    private lazy var libraryTracksController: LibraryTracksViewController = LibraryTracksViewController()
//    private lazy var libraryArtistsController: LibraryArtistsViewController = LibraryArtistsViewController()
//    private lazy var libraryAlbumsController: LibraryAlbumsViewController = LibraryAlbumsViewController()
//    private lazy var libraryGenresController: LibraryGenresViewController = LibraryGenresViewController()
//    private lazy var libraryDecadesController: LibraryDecadesViewController = LibraryDecadesViewController()
//    
//    private lazy var tuneBrowserViewController: TuneBrowserViewController = TuneBrowserViewController()
//    
//    private lazy var playlistsViewController: PlaylistsViewController = PlaylistsViewController()
    
    lazy var messenger: Messenger = Messenger(for: self)
    
    var eventMonitor: EventMonitor! = EventMonitor()
    
    var gesturesPreferences: GesturesControlsPreferences {preferences.controlsPreferences.gestures}
    
    // One-time setup
    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        // TODO: Clean this up
        theWindow.setIsVisible(false)
        initWindow()
        theWindow.setIsVisible(false)
        
        theWindow.delegate = self
        
        setUpEventHandling()
        
        if unifiedPlayerUIState.sidebarItems.contains(.chaptersListItem) {
            addChaptersListView()
        }
        
        messenger.subscribe(to: .UnifiedPlayer.showModule, handler: showModule(forItem:))
        messenger.subscribe(to: .UnifiedPlayer.hideModule, handler: hideModule(forItem:))
        
        messenger.subscribe(to: .View.togglePlayQueue, handler: showPlayQueue)
        messenger.subscribe(to: .View.toggleEffects, handler: toggleEffects)
        messenger.subscribe(to: .View.toggleChaptersList, handler: viewChaptersList)
        messenger.subscribe(to: .View.toggleLyrics, handler: toggleLyrics)
//        messenger.subscribe(to: .View.toggleVisualizer, handler: toggleVisualizer)
        messenger.subscribe(to: .View.toggleWaveform, handler: toggleWaveform)
        messenger.subscribe(to: .View.changeWindowCornerRadius, handler: changeWindowCornerRadius(to:))
        
        messenger.subscribe(to: .Player.trackTransitioned, handler: trackTransitioned(notif:))
        
        messenger.subscribeAsync(to: .Player.trackInfoUpdated, handler: lyricsLoaded(notif:), filter: {notif in
            notif.updatedFields.contains(.lyrics) && !notif.destructiveUpdate
        })
        
        messenger.subscribe(to: .Application.willExit, handler: preApplicationExit)
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.captionTextColor, changeReceiver: logoImage)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, changeReceiver: rootContainerBox)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.buttonColor, changeReceivers: buttonColorChangeReceivers)
    }
    
    // Set window properties
    private func initWindow() {
        
        theWindow.makeKeyAndOrderFront(self)
        
        changeWindowCornerRadius(to: playerUIState.cornerRadius)
        playerViewController.forceLoadingOfView()
        
        rootSplitView.addAndAnchorSubView(playerViewController.view, underArrangedSubviewAt: 0)
        rootSplitView.addAndAnchorSubView(waveformViewController.view, underArrangedSubviewAt: 1)
        showOrHideWaveform()
        
        browserSplitView.addAndAnchorSubView(sidebarController.view, underArrangedSubviewAt: 0)
        browserSplitView.delegate = self
        browserSplitView.subviews.first?.showIf(unifiedPlayerUIState.isSidebarShown)
        
        tabGroup.addAndAnchorSubView(forController: playQueueController)
        tabGroup.selectTabViewItem(at: 0)
        
        viewPopupMenuContainer.forceLoadingOfView()
        btnViewMenu.menu?.importItems(from: viewPopupMenuContainer.popupMenu)
        
//        tabGroup.addAndAnchorSubView(forController: libraryTracksController)
//        tabGroup.addAndAnchorSubView(forController: libraryArtistsController)
//        tabGroup.addAndAnchorSubView(forController: libraryAlbumsController)
//        tabGroup.addAndAnchorSubView(forController: libraryGenresController)
//        tabGroup.addAndAnchorSubView(forController: libraryDecadesController)
//
//        tabGroup.addAndAnchorSubView(forController: tuneBrowserViewController)
//
//        tabGroup.addAndAnchorSubView(forController: playlistsViewController)
    }
    
    override func destroy() {
        
        close()
        
        eventMonitor.stopMonitoring()
        eventMonitor = nil
        
//        [playerController, sidebarController, playQueueController, libraryTracksController, libraryArtistsController, libraryAlbumsController, libraryGenresController, libraryDecadesController, tuneBrowserViewController, playlistsViewController].forEach {$0.destroy()}
        
        [playerViewController, sidebarController, playQueueController, waveformViewController, lyricsSheetViewController].forEach {$0.destroy()}
        
        effectsViewLoader.destroy()
        chaptersListViewLoader.destroy()
        
        messenger.unsubscribeFromAll()
    }
    
    // MARK: Actions -----------------------------------------------------------
    
    // Quits the app
    @IBAction func quitAction(_ sender: AnyObject) {
        
        preApplicationExit()
        NSApp.terminate(self)
    }
    
    private func preApplicationExit() {
        unifiedPlayerUIState.windowFrame = theWindow.frame
    }
    
    // Minimizes the window (and any child windows)
    @IBAction func minimizeAction(_ sender: AnyObject) {
        theWindow.miniaturize(self)
    }
    
    @IBAction func showEffectsPanelAction(_ sender: AnyObject) {
        showEffects()
    }
    
    @IBAction func toggleSidebarAction(_ sender: AnyObject) {
        
        unifiedPlayerUIState.isSidebarShown.toggle()
        browserSplitView.subviews.first?.showIf(unifiedPlayerUIState.isSidebarShown)
    }
    
    // MARK: Message handling -----------------------------------------------------------
    
    private func toggleEffects() {
        attachedSheetViewController == effectsSheetViewController ? hideEffects() : showEffects()
    }
    
    private func showEffects() {
        
        dismissAttachedSheet()
        playerViewController.presentAsSheet(effectsSheetViewController)
        appDelegate.playQueueMenuRootItem.disable()
    }
    
    private func hideEffects() {
        effectsSheetViewController.endSheet()
    }
    
    func changeWindowCornerRadius(to radius: CGFloat) {
        rootContainerBox.cornerRadius = radius.clamped(to: 0...20)
    }
    
    private func showModule(forItem item: UnifiedPlayerSidebarItem) {
        
////        if tab == .playlists {
////            messenger.publish(.playlists_showPlaylist, payload: item.displayName)
////            
////        } else if tab == .fileSystem,
////                  let folder = item.tuneBrowserFolder, let tree = item.tuneBrowserTree {
////                       
////                   tuneBrowserViewController.showFolder(folder, inTree: tree, updateHistory: true)
////               }

        switch item.module {
            
        case .playQueue:
            showPlayQueue()
            
        case .chaptersList:
            showChaptersList()
            
        default:
            
            return
        }
    }
    
    private func toggleWaveform() {
        
        unifiedPlayerUIState.isWaveformShown.toggle()
        showOrHideWaveform()
    }
    
    private func showOrHideWaveform() {
        rootSplitView.subviews[1].showIf(unifiedPlayerUIState.isWaveformShown)
    }
    
    private func showPlayQueue() {
        
        tabGroup.selectTabViewItem(at: 0)
        appDelegate.playQueueMenuRootItem.enable()
    }
    
    private func showChaptersList() {
        
        tabGroup.selectLastTabViewItem(self)
        appDelegate.playQueueMenuRootItem.disable()
    }
    
    private func toggleLyrics() {
        attachedSheetViewController == lyricsSheetViewController ? hideLyrics() : showLyrics()
    }
    
    private func showLyrics() {
        
        dismissAttachedSheet()
        playerViewController.presentAsSheet(lyricsSheetViewController)
        appDelegate.playQueueMenuRootItem.disable()
    }
    
    private func hideLyrics() {
        lyricsSheetViewController.endSheet()
    }
    
    private func hideModule(forItem item: UnifiedPlayerSidebarItem) {
        
        switch item.module {
            
        case .chaptersList:
            closeChaptersList()
            
        default:
            return
        }
    }
    
    private func viewChaptersList() {
        
        addChaptersListView()
        showChaptersList()
    }
    
    private func addChaptersListView() {
        
        if tabGroup.tabViewItems.count == 1 {
            tabGroup.addAndAnchorSubView(forController: chaptersListController)
        }
    }
    
    private func closeChaptersList() {
        
        if tabGroup.tabViewItems.count > 1 {
            tabGroup.tabViewItems.removeLast()
        }
    }
    
    private func trackTransitioned(notif: TrackTransitionNotification) {
        
        if let newTrack = notif.endTrack {
            
            if newTrack.hasChapters, preferences.playQueuePreferences.showChaptersList.value {
                viewChaptersList()
                
            } else {
                closeChaptersList()
            }
            
            if preferences.metadataPreferences.lyrics.showWindowWhenPresent.value,
                newTrack.hasLyrics {
                
                showLyrics()
            }
            
        } else {
            closeChaptersList()
        }
    }
    
    private func lyricsLoaded(notif: TrackInfoUpdatedNotification) {
        
        if preferences.metadataPreferences.lyrics.showWindowWhenPresent.value,
           playbackInfoDelegate.playingTrack == notif.updatedTrack,
           notif.updatedTrack.hasLyrics,
           !appModeManager.isShowingLyrics {
            
            showLyrics()
        }
    }
}

extension UnifiedPlayerWindowController: NSSplitViewDelegate {
    
    func splitView(_ splitView: NSSplitView, shouldHideDividerAt dividerIndex: Int) -> Bool {
        !unifiedPlayerUIState.isSidebarShown
    }
}

extension UnifiedPlayerWindowController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        
        logoImage.colorChanged(systemColorScheme.captionTextColor)
        
        rootContainerBox.fillColor = systemColorScheme.backgroundColor
        
        buttonColorChangeReceivers.forEach {
            $0.colorChanged(systemColorScheme.buttonColor)
        }
    }
}

extension UnifiedPlayerWindowController: NSWindowDelegate {
    
    func windowDidResize(_ notification: Notification) {
        playerViewController.windowResized()
    }
}
