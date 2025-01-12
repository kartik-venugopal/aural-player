//
//  LibraryWindowController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class LibraryWindowController: NSWindowController {
    
    override var windowNibName: NSNib.Name? {"LibraryWindow"}
    
    @IBOutlet weak var rootContainer: NSBox!
    @IBOutlet weak var controlsBox: NSBox!
    
    @IBOutlet weak var btnClose: TintedImageButton!
    @IBOutlet weak var lblCaption: NSTextField!
    
    @IBOutlet weak var splitView: NSSplitView!
    
    // The tab group that switches between the 4 playlist views
    @IBOutlet weak var tabGroup: NSTabView!
    
    // Spinner that shows progress when tracks are being added to any of the playlists.
    @IBOutlet weak var progressSpinner: NSProgressIndicator!
    
    @IBOutlet weak var buildProgressView: NSBox!
    @IBOutlet weak var buildIndeterminateSpinner: NSImageView!
    @IBOutlet weak var buildProgressSpinner: ProgressArc!
    @IBOutlet weak var lblBuildStats: NSTextField!
    
    private lazy var sidebarController: LibrarySidebarViewController = LibrarySidebarViewController()
    
    private lazy var libraryTracksController: LibraryTracksViewController = LibraryTracksViewController()
    private lazy var libraryArtistsController: LibraryArtistsViewController = LibraryArtistsViewController()
    private lazy var libraryAlbumsController: LibraryAlbumsViewController = LibraryAlbumsViewController()
    private lazy var libraryGenresController: LibraryGenresViewController = LibraryGenresViewController()
    private lazy var libraryDecadesController: LibraryDecadesViewController = LibraryDecadesViewController()
    private lazy var libraryImportedPlaylistsController: LibraryImportedPlaylistsViewController = .init()
    
    private lazy var tuneBrowserViewController: TuneBrowserViewController = TuneBrowserViewController()
    private lazy var playlistsViewController: PlaylistsViewController = PlaylistsViewController()
    private lazy var favoritesViewController: FavoritesManagerViewController = FavoritesManagerViewController()
    private lazy var bookmarksViewController: BookmarksManagerViewController = BookmarksManagerViewController()
    private lazy var historyRecentItemsViewController: HistoryRecentItemsViewController = HistoryRecentItemsViewController()
    
    private lazy var messenger: Messenger = Messenger(for: self)
    
    private lazy var buildProgressUpdateTask: RepeatingTaskExecutor = .init(intervalMillis: 500, task: {[weak self] in self?.updateBuildProgress()}, queue: .main)
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        splitView.showIf(libraryDelegate.isBuilt)
        
        let sidebarView: NSView = sidebarController.view
        splitView.arrangedSubviews[0].addSubview(sidebarView)
        sidebarView.anchorToSuperview()
        
        let libraryTracksView: NSView = libraryTracksController.view
        tabGroup.tabViewItem(at: 0).view?.addSubview(libraryTracksView)
        libraryTracksView.anchorToSuperview()
        
        let libraryArtistsView: NSView = libraryArtistsController.view
        tabGroup.tabViewItem(at: 1).view?.addSubview(libraryArtistsView)
        libraryArtistsView.anchorToSuperview()
        
        let libraryAlbumsView: NSView = libraryAlbumsController.view
        tabGroup.tabViewItem(at: 2).view?.addSubview(libraryAlbumsView)
        libraryAlbumsView.anchorToSuperview()
        
        let libraryGenresView: NSView = libraryGenresController.view
        tabGroup.tabViewItem(at: 3).view?.addSubview(libraryGenresView)
        libraryGenresView.anchorToSuperview()
        
        let libraryDecadesView: NSView = libraryDecadesController.view
        tabGroup.tabViewItem(at: 4).view?.addSubview(libraryDecadesView)
        libraryDecadesView.anchorToSuperview()
        
        let libraryImportedPlaylistsView: NSView = libraryImportedPlaylistsController.view
        tabGroup.tabViewItem(at: 5).view?.addSubview(libraryImportedPlaylistsView)
        libraryImportedPlaylistsView.anchorToSuperview()
        
        let tuneBrowserView: NSView = tuneBrowserViewController.view
        tabGroup.tabViewItem(at: 6).view?.addSubview(tuneBrowserView)
        tuneBrowserView.anchorToSuperview()
        
        let playlistsView: NSView = playlistsViewController.view
        tabGroup.tabViewItem(at: 7).view?.addSubview(playlistsView)
        playlistsView.anchorToSuperview()
        
        let favoritesView: NSView = favoritesViewController.view
        tabGroup.tabViewItem(at: 8).view?.addSubview(favoritesView)
        favoritesView.anchorToSuperview()
        
        let bookmarksView: NSView = bookmarksViewController.view
        tabGroup.tabViewItem(at: 9).view?.addSubview(bookmarksView)
        bookmarksView.anchorToSuperview()
        
        let historyRecentItemsView: NSView = historyRecentItemsViewController.view
        tabGroup.tabViewItem(at: 10).view?.addSubview(historyRecentItemsView)
        historyRecentItemsView.anchorToSuperview()
        
        let windowShownFilter = {[weak self] in self?.theWindow.isVisible ?? false}
        messenger.subscribeAsync(to: .Library.startedReadingFileSystem, handler: startedReadingFileSystem, filter: windowShownFilter)
        messenger.subscribeAsync(to: .Library.startedAddingTracks, handler: startedAddingTracks, filter: windowShownFilter)
        messenger.subscribeAsync(to: .Library.doneAddingTracks, handler: doneAddingTracks, filter: windowShownFilter)
        
        messenger.subscribe(to: .Library.showBrowserTabForItem, handler: showBrowserTab(forItem:))
        messenger.subscribe(to: .Library.showBrowserTabForCategory, handler: showBrowserTab(forCategory:))
        messenger.subscribe(to: .View.changeWindowCornerRadius, handler: changeWindowCornerRadius(_:))
        
        fontSchemesManager.registerObserver(self)
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, changeReceiver: rootContainer)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.buttonColor, changeReceiver: btnClose)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.captionTextColor, changeReceiver: lblCaption)
        
        changeWindowCornerRadius(playerUIState.cornerRadius)
        
        // TODO: Temporary, remove this !!!
        tabGroup.selectTabViewItem(at: 10)
        
        displayBuildProgress()
    }
    
    override func destroy() {
        
        close()
        buildProgressUpdateTask.pause()
        messenger.unsubscribeFromAll()
        
        [sidebarController, libraryTracksController, libraryArtistsController, libraryAlbumsController, libraryGenresController,
         libraryDecadesController, libraryImportedPlaylistsController, playlistsViewController, tuneBrowserViewController].forEach {
            
            $0.destroy()
        }
    }
    
    override func showWindow(_ sender: Any?) {
        
        super.showWindow(sender)
        displayBuildProgress()
    }
    
    private func displayBuildProgress() {
        
        let buildProgress = libraryDelegate.buildProgress
        guard buildProgress.isBeingModified else {
            
            if buildProgressView.isShown {
                
                buildProgressView.hide()
                buildIndeterminateSpinner.animates = false
                buildProgressUpdateTask.stop()
            }
            
            sidebarController.sidebarView.enable()
            
            return
        }
        
        if buildProgressView.isHidden {
            buildProgressView.show()
        }
        
        // TODO: Disable the rest of the window (mouse hover response and clicking on the right side details panel)
        
        if buildProgress.startedReadingFiles, let stats = buildProgress.buildStats {
            
            lblBuildStats.stringValue = "Reading \(stats.filesToRead) tracks and \(stats.playlistsToRead) playlists ..."
            
            buildIndeterminateSpinner.hide()
            buildIndeterminateSpinner.animates = false
            
            buildProgressSpinner.show()
            buildProgressUpdateTask.startOrResume()
            
        } else {
            
            lblBuildStats.stringValue = "Reading source folders: '\(library.sourceFolders.map {$0.path})' ..."
            
            buildIndeterminateSpinner.animates = true
            buildIndeterminateSpinner.show()
            
            buildProgressSpinner.hide()
        }
    }
    
    private func updateBuildProgress() {
        
        if let progressPercentage = libraryDelegate.buildProgress.buildStats?.progressPercentage {
            buildProgressSpinner.percentage = progressPercentage
        }
    }
    
    @IBAction func closeAction(_ sender: Any) {
        
        windowLayoutsManager.toggleWindow(withId: .library)
        buildProgressUpdateTask.pause()
    }
    
    private func showBrowserTab(forItem item: LibrarySidebarItem) {
        
        let tab = item.browserTab
        
        if tab == .playlists {
            messenger.publish(.playlists_showPlaylist, payload: item.displayName)
            
        } else if tab == .fileSystem,
           let folder = item.tuneBrowserFolder, let tree = item.tuneBrowserTree {
            
            tuneBrowserViewController.showFolder(folder, inTree: tree, updateHistory: true)
            
        } else if tab == .favorites {
            favoritesViewController.showTab(for: item)
        }
        
        tabGroup.selectTabViewItem(at: tab.rawValue)
    }
    
    private func showBrowserTab(forCategory category: LibrarySidebarCategory) {

        if category == .bookmarks {
            tabGroup.selectTabViewItem(at: 9)
        }
    }
    
    // MARK: Message handling -----------------------------------------------------------
    
    private func startedReadingFileSystem() {
        displayBuildProgress()
    }
    
    private func startedAddingTracks() {
        displayBuildProgress()
    }
    
    private func doneAddingTracks() {
        
        buildProgressUpdateTask.stop()
        buildProgressView.hide()
        
        splitView.show()
    }
}

extension LibraryWindowController: FontSchemeObserver {
    
    func fontSchemeChanged() {
        lblCaption.font = systemFontScheme.captionFont
    }
}

extension LibraryWindowController: ColorSchemeObserver {
    
    // MARK: Theming -----------------------------------------------------------
    
    func colorSchemeChanged() {
        
        rootContainer.fillColor = systemColorScheme.backgroundColor
        btnClose.contentTintColor = systemColorScheme.buttonColor
        lblCaption.textColor = systemColorScheme.captionTextColor
    }
    
    private func changeWindowCornerRadius(_ radius: CGFloat) {
        rootContainer.cornerRadius = radius
    }
}
