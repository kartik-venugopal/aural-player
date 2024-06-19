//
//  PlayQueueViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class PlayQueueViewController: TrackListTableViewController {
    
    /// Override this !!!
    var playQueueView: PlayQueueView {
        .simple
    }

    override var isTrackListBeingModified: Bool {playQueueDelegate.isBeingModified}
    
    override var trackList: TrackListProtocol! {playQueueDelegate}
    
    // MARK: Menu items (for menu delegate)
    
    @IBOutlet weak var playNowMenuItem: NSMenuItem!
    @IBOutlet weak var playNextMenuItem: NSMenuItem!
    
    @IBOutlet weak var viewChaptersListMenuItem: NSMenuItem!
    @IBOutlet weak var jumpToChapterMenuItem: NSMenuItem!
    @IBOutlet weak var chaptersMenu: NSMenu!
    
    @IBOutlet weak var favoriteMenu: NSMenu!
    @IBOutlet weak var favoriteMenuItem: NSMenuItem!
    
    @IBOutlet weak var favoriteTrackMenuItem: NSMenuItem!
//    @IBOutlet weak var favoriteArtistMenuItem: NSMenuItem!
//    @IBOutlet weak var favoriteAlbumMenuItem: NSMenuItem!
//    @IBOutlet weak var favoriteGenreMenuItem: NSMenuItem!
//    @IBOutlet weak var favoriteDecadeMenuItem: NSMenuItem!
    @IBOutlet weak var favoriteFolderMenuItem: NSMenuItem!
    
    @IBOutlet weak var moveTracksUpMenuItem: NSMenuItem!
    @IBOutlet weak var moveTracksDownMenuItem: NSMenuItem!
    @IBOutlet weak var moveTracksToTopMenuItem: NSMenuItem!
    @IBOutlet weak var moveTracksToBottomMenuItem: NSMenuItem!
    
    @IBOutlet weak var contextMenu: NSMenu!
    @IBOutlet weak var infoMenuItem: NSMenuItem!
    
//    @IBOutlet weak var playlistNamesMenu: NSMenu!
    
    // Popup view that displays a brief notification when a selected track is added/removed to/from the Favorites list
    lazy var infoPopup: InfoPopupViewController = .instance
    
    lazy var trackInfoSheetViewController: TrackInfoSheetViewController = .init()
    
    lazy var messenger: Messenger = .init(for: self)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.menu = contextMenu
        
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.activeControlColor, handler: activeControlColorChanged(_:))
        
        messenger.subscribeAsync(to: .PlayQueue.tracksAdded, handler: tracksAdded(_:))
        messenger.subscribeAsync(to: .Player.trackTransitioned, handler: trackTransitioned(_:))
        messenger.subscribe(to: .PlayQueue.refresh, handler: tableView.reloadData)
    }
    
    override func viewWillAppear() {
        
        super.viewWillAppear()
        
        if contextMenu != nil {
            
            contextMenu.delegate = self
            
//            for item in contextMenu.items + favoriteMenu.items + playlistNamesMenu.items {
            for item in contextMenu.items + favoriteMenu.items {
                item.target = self
            }
        }
    }
    
    override func tracksMovedByDragDrop(minReloadIndex: Int, maxReloadIndex: Int) {
        messenger.publish(.PlayQueue.updateSummary)
    }
    
    override func notifyReloadTable() {
        messenger.publish(.PlayQueue.refresh)
    }
    
    override func destroy() {
        
        super.destroy()
        messenger.unsubscribeFromAll()
    }
    
    // MARK: Commands --------------------------------------------------------------------------------------------------------
    
    @IBAction func playSelectedTrackAction(_ sender: Any) {
        playSelectedTrack()
    }
    
    func playSelectedTrack() {
        
        if let firstSelectedRow = selectedRows.min() {
            messenger.publish(TrackPlaybackCommandNotification(index: firstSelectedRow))
        }
    }
    
    func showPlayingTrack() {
        
        if let indexOfPlayingTrack = playQueueDelegate.currentTrackIndex {
            selectTrack(at: indexOfPlayingTrack)
        }
    }
    
    // MARK: Notification / command handling ----------------------------------------------------------------------------------------
    
    func activeControlColorChanged(_ newColor: PlatformColor) {
        
        if let playingTrackIndex = playQueueDelegate.currentTrackIndex {
            tableView.reloadRows([playingTrackIndex])
        }
    }
    
    func tracksAdded(_ notif: PlayQueueTracksAddedNotification) {
        tracksAdded(at: notif.trackIndices)
    }
    
    func trackTransitioned(_ notification: TrackTransitionNotification) {
    
        let refreshIndexes: [Int] = Set([notification.beginTrack, notification.endTrack]
                                            .compactMap {$0})
                                            .compactMap {playQueueDelegate.indexOfTrack($0)}

        // If this is not done async, the row view could get garbled.
        // (because of other potential simultaneous updates - e.g. PlayingTrackInfoUpdated)
        DispatchQueue.main.async {
            self.tableView.reloadRows(refreshIndexes)
        }
    }
    
    // MARK: Data source functions
    
    @objc override func loadFinderTracks(from files: [URL]) {
        doLoadFinderTracks(from: files)
    }
    
    @objc override func loadFinderTracks(from files: [URL], atPosition row: Int) {
        doLoadFinderTracks(from: files, atPosition: row)
    }
    
    var shouldAutoplayAfterAdding: Bool {
        
        let autoplayAfterAdding: Bool = preferences.playbackPreferences.autoplayAfterAddingTracks.value
        lazy var option: PlaybackPreferences.AutoplayAfterAddingOption = preferences.playbackPreferences.autoplayAfterAddingOption.value
        lazy var playerIsStopped: Bool = playbackInfoDelegate.state.isStopped
        return autoplayAfterAdding && (option == .always || playerIsStopped)
    }
    
    func doLoadFinderTracks(from files: [URL], atPosition row: Int? = nil) {
        
        let addMode = preferences.playQueuePreferences.dragDropAddMode.value
        let clearQueue: Bool = addMode == .replace || (addMode == .hybrid && NSEvent.optionFlagSet)
        
        playQueueDelegate.loadTracks(from: files, atPosition: row, params: .init(clearQueue: clearQueue, autoplay: shouldAutoplayAfterAdding))
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        playQueueUIState.selectedRows = self.selectedRows
    }
    
    // MARK: Method overrides --------------------------------------------------------------------------------
    
    // Invokes the Open file dialog, to allow the user to add tracks/playlists to the app playlist
    override func importFilesAndFolders() {
        
        if fileOpenDialog.runModal() == .OK {
            playQueueDelegate.loadTracks(from: fileOpenDialog.urls, params: .init(autoplay: shouldAutoplayAfterAdding))
        }
    }
    
    /**
        The Play Queue needs to update the summary in the case when tracks were reordered, because, if a track
        is playing, it may have moved.
     */
    
    override func doMoveTracksUp() {
        
        super.doMoveTracksUp()
        updateSummary()
    }

    override func doMoveTracksDown() {
        
        super.doMoveTracksDown()
        updateSummary()
    }

    override func doMoveTracksToTop() {
        
        super.doMoveTracksToTop()
        updateSummary()
    }

    override func doMoveTracksToBottom() {
        
        super.doMoveTracksToBottom()
        updateSummary()
    }
    
    func tracksRemoved(firstRemovedRow: Int) {
        
        // Update all rows from the first (i.e. smallest index) removed row, down to the end of the track list.
        let lastRowAfterRemove = playQueueDelegate.size - 1
        
        // Tell the playlist view that the number of rows has changed (should result in removal of rows)
        noteNumberOfRowsChanged()
        
        // This will be true unless a contiguous block of tracks was removed from the bottom of the track list.
        if firstRemovedRow <= lastRowAfterRemove {
            reloadTableRows(firstRemovedRow...lastRowAfterRemove)
        }
    }
}
