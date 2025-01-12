//
//  PlaylistViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class PlaylistViewController: TrackListTableViewController {
    
    unowned var playlist: Playlist! = nil {
        
        didSet {
            reloadTable()
        }
    }
    
    override var isTrackListBeingModified: Bool {playlist?.isBeingModified ?? false}
    
    override var trackList: TrackListProtocol! {playlist}
    
    // MARK: Menu items (for menu delegate)
    
    @IBOutlet weak var playNowMenuItem: NSMenuItem!
    @IBOutlet weak var playNextMenuItem: NSMenuItem!
    
    @IBOutlet weak var favoriteMenu: NSMenu!
    @IBOutlet weak var favoriteMenuItem: NSMenuItem!
    
    @IBOutlet weak var favoriteTrackMenuItem: NSMenuItem!
    @IBOutlet weak var favoriteArtistMenuItem: NSMenuItem!
    @IBOutlet weak var favoriteAlbumMenuItem: NSMenuItem!
    @IBOutlet weak var favoriteGenreMenuItem: NSMenuItem!
    @IBOutlet weak var favoriteDecadeMenuItem: NSMenuItem!
    
    @IBOutlet weak var moveTracksUpMenuItem: NSMenuItem!
    @IBOutlet weak var moveTracksDownMenuItem: NSMenuItem!
    @IBOutlet weak var moveTracksToTopMenuItem: NSMenuItem!
    @IBOutlet weak var moveTracksToBottomMenuItem: NSMenuItem!
    
    @IBOutlet weak var contextMenu: NSMenu!
    @IBOutlet weak var infoMenuItem: NSMenuItem!
    
    @IBOutlet weak var playlistNamesMenu: NSMenu!
    
    // Popup view that displays a brief notification when a selected track is added/removed to/from the Favorites list
    lazy var infoPopup: InfoPopupViewController = .instance
    
    lazy var messenger: Messenger = .init(for: self)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.menu = contextMenu
        
        messenger.subscribeAsync(to: .playlist_tracksAdded, handler: tracksAdded(_:), filter: {[weak self] notif in
            notif.playlistName == self?.playlist.name
        })
        
        messenger.subscribe(to: .playlist_addChosenFiles, handler: addChosenTracks(_:))
        
        messenger.subscribe(to: .playlist_copyTracks, handler: copyTracks(_:))
        messenger.subscribe(to: .playlist_refresh, handler: reloadTable)
    }
    
    override func viewWillAppear() {
        
        super.viewWillAppear()
        
        if contextMenu != nil {
            
            contextMenu.delegate = self
            
            for item in contextMenu.items + favoriteMenu.items + playlistNamesMenu.items {
                item.target = self
            }
        }
    }
    
    override func notifyReloadTable() {
        messenger.publish(.playlist_refresh)
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
        
        if let firstSelectedRow = selectedRows.min(), let track = playlist[firstSelectedRow] {
            playQueueDelegate.enqueueToPlayNow(tracks: [track], clearQueue: false)
        }
    }
    
    // MARK: Notification / command handling ----------------------------------------------------------------------------------------
    
    private func tracksAdded(_ notif: PlaylistTracksAddedNotification) {
        tracksAdded(at: notif.trackIndices)
    }
    
    // MARK: Data source functions
    
    func tableViewSelectionDidChange(_ notification: Notification) {
//        playQueueUIState.selectedRows = self.selectedRows
    }
    
    private func copyTracks(_ notif: CopyTracksToPlaylistCommand) {
        
        guard let destinationPlaylist = playlistsManager.userDefinedObject(named: notif.destinationPlaylistName) else {return}
        
        destinationPlaylist.addTracks(notif.tracks)
        
        // If tracks were added to the displayed playlist, update the table view.
        if destinationPlaylist == playlist {
            tableView.noteNumberOfRowsChanged()
        }
    }
}
