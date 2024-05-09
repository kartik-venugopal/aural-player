//
//  PlaylistContainerViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class PlaylistContainerViewController: NSViewController {
    
    override var nibName: NSNib.Name? {"PlaylistContainer"}
    
    unowned var playlist: Playlist!
    
    @IBOutlet weak var lblCaption: NSTextField!
    @IBOutlet weak var lblTracksSummary: NSTextField!
    @IBOutlet weak var lblDurationSummary: NSTextField!
    
    // Spinner that shows progress when tracks are being added to the play queue.
    @IBOutlet weak var progressSpinner: NSProgressIndicator!
    
    @IBOutlet weak var tabButtonsContainer: NSBox!
    
    // The tab group that switches between the 4 playlist views
    @IBOutlet weak var tabGroup: NSTabView!
    
    @IBOutlet weak var btnSimpleView: TrackListTabButton!
    @IBOutlet weak var btnExpandedView: TrackListTabButton!
    
    var buttonColorChangeReceivers: [ColorSchemePropertyChangeReceiver] = []
    
    lazy var tabButtons: [TrackListTabButton] = [btnSimpleView, btnExpandedView]
    
    @IBOutlet weak var sortOrderMenuItemView: SortOrderMenuItemView!
    
    @IBOutlet weak var simpleViewController: PlaylistSimpleViewController!
    @IBOutlet weak var expandedViewController: PlaylistSimpleViewController!
    lazy var controllers: [PlaylistViewController] = [simpleViewController, expandedViewController]
    
    lazy var searchWindowController: SearchWindowController = .shared
    
    lazy var fileOpenDialog = DialogsAndAlerts.openFilesAndFoldersDialog
    lazy var alertDialog: AlertWindowController = .instance
    lazy var saveDialog = DialogsAndAlerts.savePlaylistDialog
    
    var currentViewController: PlaylistSimpleViewController {
        tabGroup.selectedIndex == 0 ? simpleViewController : expandedViewController
    }
    
    lazy var messenger: Messenger = Messenger(for: self)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        controllers.forEach {
            
            $0.forceLoadingOfView()
            $0.playlist = playlist
        }
        
        initializeView()
        setUpTheming()
        initSubscriptions()
        
        updateSummary()
    }
    
    func initializeView() {
        
        lblCaption.stringValue = playlist?.name ?? ""
        
        let simpleView = simpleViewController.view
        let prettyView = expandedViewController.view
        
        for (index, view) in [simpleView, prettyView].enumerated() {
            
            tabGroup.tabViewItem(at: index).view?.addSubview(view)
            view.anchorToSuperview()
        }
        
        doSelectTab(at: 0)
    }
    
    func setUpTheming() {
        
        buttonColorChangeReceivers = [btnSimpleView, btnExpandedView]
        
        fontSchemesManager.registerObserver(self)
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperties: [\.buttonColor, \.inactiveControlColor], changeReceivers: buttonColorChangeReceivers)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, changeReceiver: tabButtonsContainer)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.captionTextColor, changeReceiver: lblCaption)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.secondaryTextColor, handler: secondaryTextColorChanged(_:))
    }
    
    func initSubscriptions() {
        
        messenger.subscribeAsync(to: .playlists_startedAddingTracks, handler: startedAddingTracks)
        messenger.subscribeAsync(to: .playlist_tracksAdded, handler: updateSummary)
        messenger.subscribeAsync(to: .playlists_doneAddingTracks, handler: doneAddingTracks)
        
        messenger.subscribe(to: .playlists_updateSummary, handler: updateSummary)
    }
    
    func playSelectedTrack() {
        currentViewController.playSelectedTrack()
    }
    
    func selectAllTracks() {
        currentViewController.selectAll()
    }
    
    func clearSelection() {
        currentViewController.clearSelection()
    }
    
    func invertSelection() {
        currentViewController.invertSelection()
    }
    
    // Removes all items from the playlist
    func removeAllTracks() {
        
        guard playlist.size > 0, !checkIfPlaylistIsBeingModified() else {return}
        
        playQueueDelegate.removeAllTracks()
        
        // Tell the play queue UI to refresh its views.
        messenger.publish(.PlayQueue.refresh)
        
        updateSummary()
    }
    
    func pageUp() {
        currentViewController.pageUp()
    }
    
    func pageDown() {
        currentViewController.pageDown()
    }
    
    func scrollToTop() {
        currentViewController.scrollToTop()
    }
    
    func scrollToBottom() {
        currentViewController.scrollToBottom()
    }
    
    private func checkIfPlaylistIsBeingModified() -> Bool {
        
        let playlistBeingModified = playlist.isBeingModified
        
        if playlistBeingModified {
            
            alertDialog.showAlert(.error, "Playlist not modified", "The Playlist cannot be modified while tracks are being added", "Please wait till the Playlist is done adding tracks ...")
        }
        
        return playlistBeingModified
    }
    
    // MARK: Notification handling ----------------------------------------------------------------------------------
    
    func playlistRenamed(to newPlaylistName: String) {
        lblCaption.stringValue = newPlaylistName
    }
    
    func tracksCopiedToPlaylist() {
        
        currentViewController.tracksAppended()
        updateSummary()
    }
    
    func startedAddingTracks() {
        
        progressSpinner.startAnimation(nil)
        progressSpinner.show()
    }
    
    func doneAddingTracks() {
        
        progressSpinner.hide()
        progressSpinner.stopAnimation(nil)
        
        updateSummary()
    }
    
    func updateSummary() {
        
        guard let displayedPlaylist = self.playlist else {
            
            lblTracksSummary.stringValue = "0 tracks"
            lblDurationSummary.stringValue = "0:00"
            return
        }
        
        let numTracks = displayedPlaylist.size
        lblTracksSummary.stringValue = "\(numTracks) \(numTracks == 1 ? "track" : "tracks")"
        lblDurationSummary.stringValue = ValueFormatter.formatSecondsToHMS(displayedPlaylist.duration)
    }
    
    func search() {
        searchWindowController.showWindow(self)
    }
    
    override func destroy() {
        
        controllers.forEach {$0.destroy()}
        messenger.unsubscribeFromAll()
    }
}

extension PlaylistContainerViewController: NSTabViewDelegate {
    
    func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        
//        playQueueUIState.currentView = tabGroup.selectedIndex == 0 ? .simple : .expanded
    }
}

extension PlaylistContainerViewController: FontSchemeObserver {
    
    func fontSchemeChanged() {
        
        lblCaption.font = systemFontScheme.captionFont
        
        [lblTracksSummary, lblDurationSummary].forEach {
            $0.font = systemFontScheme.smallFont
        }
    }
}

extension PlaylistContainerViewController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        
        [btnSimpleView, btnExpandedView].forEach {
            $0.redraw()
        }
        
        tabButtonsContainer.fillColor = systemColorScheme.backgroundColor
        
        lblCaption.textColor = systemColorScheme.captionTextColor
        
        [lblTracksSummary, lblDurationSummary].forEach {
            $0?.textColor = systemColorScheme.secondaryTextColor
        }
    }
    
    func secondaryTextColorChanged(_ newColor: PlatformColor) {
        updateSummary()
    }
}
