//
//  PlaylistTracksViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class PlaylistTracksViewController: TrackListTableViewController {
    
    override var nibName: NSNib.Name? {"PlaylistSimpleView"}
    
    override var rowHeight: CGFloat {30}
    
    unowned var playlist: Playlist! = nil {
        
        didSet {
            
            if playlist != nil {
                tableView.reloadData()
            }
        }
    }
    
    override var trackList: TrackListProtocol! {
        playlist
    }
    
    private lazy var messenger: Messenger = .init(for: self)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
//        colorSchemesManager.registerObserver(self, forProperties: [\.primaryTextColor, \.secondaryTextColor, \.tertiaryTextColor,
//                                                                    \.primarySelectedTextColor, \.secondarySelectedTextColor, \.tertiarySelectedTextColor, \.textSelectionColor])
        
        messenger.subscribeAsync(to: .playlist_tracksAdded, handler: tracksAdded(_:),
                                 filter: {[weak self] notif in self?.playlist?.name == notif.playlistName})
        
        messenger.subscribe(to: .playlist_addChosenFiles, handler: addChosenTracks(_:))
        
        messenger.subscribe(to: .playlist_copyTracks, handler: copyTracks(_:))
        messenger.subscribe(to: .playlist_refresh, handler: reloadTable)
    }
    
    override func view(forColumn column: NSUserInterfaceItemIdentifier, row: Int, track: Track) -> TableCellBuilder {
        
        let builder = TableCellBuilder()
        
        switch column {
            
        case .cid_index:
            
            return builder.withText(text: "\(row + 1)",
                                                   inFont: systemFontScheme.normalFont, andColor: systemColorScheme.tertiaryTextColor,
                                                   selectedTextColor: systemColorScheme.tertiarySelectedTextColor)

        case .cid_trackName:
            
            let titleAndArtist = track.titleAndArtist
            
            if let artist = titleAndArtist.artist {
                
                return builder.withAttributedText(strings: [(text: artist + "  ", font: systemFontScheme.normalFont, color: systemColorScheme.secondaryTextColor),
                                                                       (text: titleAndArtist.title, font: systemFontScheme.normalFont, color: systemColorScheme.primaryTextColor)],
                                                             selectedTextColors: [systemColorScheme.secondarySelectedTextColor, systemColorScheme.primarySelectedTextColor])
            } else {
                
                return builder.withAttributedText(strings: [(text: titleAndArtist.title,
                                                                        font: systemFontScheme.normalFont,
                                                                        color: systemColorScheme.primaryTextColor)], selectedTextColors: [systemColorScheme.primarySelectedTextColor])
            }
            
        case .cid_duration:
            
            return builder.withText(text: ValueFormatter.formatSecondsToHMS(track.duration),
                                               inFont: systemFontScheme.normalFont, andColor: systemColorScheme.tertiaryTextColor,
                                               selectedTextColor: systemColorScheme.tertiarySelectedTextColor)
            
        default:
            
            return builder
        }
    }
    
    // Drag / drop from other playlists into this playlist.
    override func importPlaylists(_ sourcePlaylists: [Playlist], to destRow: Int) {
        
        // Don't import this playlist into itself (will have no effect).
        super.importPlaylists(sourcePlaylists.filter {$0 != self.playlist}, to: destRow)
    }
    
    override func notifyReloadTable() {
        messenger.publish(.playlist_refresh)
    }
    
    override func destroy() {
        
        super.destroy()
        messenger.unsubscribeFromAll()
    }
    
    // ---------------------------------------------------------------------------------------------------------
    
    // MARK: Actions (control buttons)
    
//    @IBAction func moveTracksUpAction(_ sender: NSButton) {
//        moveTracksUp()
//    }
//    
//    @IBAction func moveTracksDownAction(_ sender: NSButton) {
//        moveTracksDown()
//    }
//    
//    @IBAction func moveTracksToTopAction(_ sender: NSButton) {
//        moveTracksToTop()
//    }
//    
//    @IBAction func moveTracksToBottomAction(_ sender: NSButton) {
//        moveTracksToBottom()
//    }
    
    @IBAction func doubleClickAction(_ sender: NSTableView) {
        
        if let selRow: Int = selectedRows.first,
            let selTrack = playlist[selRow] {
            
            playQueue.enqueueToPlayNow(tracks: [selTrack], clearQueue: false)
        }
    }
    
    // ---------------------------------------------------------------------------------------------------------
    
    // MARK: Actions (context menu)
    
    @IBAction func playNowAction(_ sender: NSMenuItem) {
        playQueue.enqueueToPlayNow(tracks: playlist[selectedRows], clearQueue: false)
    }
    
    @IBAction func playNowClearingPlayQueueAction(_ sender: NSMenuItem) {
        playQueue.enqueueToPlayNow(tracks: playlist[selectedRows], clearQueue: true)
    }
    
    @IBAction func playNextAction(_ sender: NSMenuItem) {
        playQueue.enqueueToPlayNext(tracks: playlist[selectedRows])
    }
    
    @IBAction func playLaterAction(_ sender: NSMenuItem) {
        playQueue.enqueueToPlayLater(tracks: playlist[selectedRows])
    }
    
    // ---------------------------------------------------------------------------------------------------------
    
    // MARK: Notification handling
    
    func colorChanged(to newColor: NSColor, forProperty property: ColorSchemeProperty) {
        
        switch property {
            
        case \.primaryTextColor, \.secondaryTextColor, \.tertiaryTextColor,
             \.primarySelectedTextColor, \.secondarySelectedTextColor, \.tertiarySelectedTextColor:
            
            let selection = selectedRows
            tableView.reloadData()
            tableView.selectRows(selection)
            
        case \.textSelectionColor:
            
            tableView.reloadRows(selectedRows)
            tableView.redoRowSelection()
            
        default:
            
            return
        }
    }
    
    private func tracksAdded(_ notif: PlaylistTracksAddedNotification) {
        
        tracksAdded(at: notif.trackIndices)
        messenger.publish(.playlists_updateSummary)
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
