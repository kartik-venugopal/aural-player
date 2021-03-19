import Cocoa

/*
 Provides actions for the Playlist menu that perform various CRUD (model) operations and view navigation operations on the playlist.
 
 NOTE - No actions are directly handled by this class. Action messages are published to another app component that is responsible for these functions.
 */
class PlaylistMenuController: NSObject, NSMenuDelegate {
    
    @IBOutlet weak var theMenu: NSMenuItem!
    
    @IBOutlet weak var playSelectedItemMenuItem: NSMenuItem!
    @IBOutlet weak var playSelectedItemDelayedMenuItem: NSMenuItem!
    
    @IBOutlet weak var moveItemsUpMenuItem: NSMenuItem!
    @IBOutlet weak var moveItemsToTopMenuItem: NSMenuItem!
    @IBOutlet weak var moveItemsDownMenuItem: NSMenuItem!
    @IBOutlet weak var moveItemsToBottomMenuItem: NSMenuItem!
    @IBOutlet weak var removeSelectedItemsMenuItem: NSMenuItem!
    
    @IBOutlet weak var insertGapsMenuItem: NSMenuItem!
    @IBOutlet weak var editGapsMenuItem: NSMenuItem!
    @IBOutlet weak var removeGapsMenuItem: NSMenuItem!
    
    @IBOutlet weak var clearSelectionMenuItem: NSMenuItem!
    @IBOutlet weak var invertSelectionMenuItem: NSMenuItem!
    @IBOutlet weak var cropSelectionMenuItem: NSMenuItem!
    
    @IBOutlet weak var expandSelectedGroupsMenuItem: NSMenuItem!
    @IBOutlet weak var collapseSelectedItemsMenuItem: NSMenuItem!
    
    @IBOutlet weak var expandAllGroupsMenuItem: NSMenuItem!
    @IBOutlet weak var collapseAllGroupsMenuItem: NSMenuItem!
    
    @IBOutlet weak var savePlaylistMenuItem: NSMenuItem!
    @IBOutlet weak var clearPlaylistMenuItem: NSMenuItem!
    
    @IBOutlet weak var searchPlaylistMenuItem: NSMenuItem!
    @IBOutlet weak var sortPlaylistMenuItem: NSMenuItem!
    
    @IBOutlet weak var scrollToTopMenuItem: NSMenuItem!
    @IBOutlet weak var scrollToBottomMenuItem: NSMenuItem!
    @IBOutlet weak var pageUpMenuItem: NSMenuItem!
    @IBOutlet weak var pageDownMenuItem: NSMenuItem!
    
    private let playlist: PlaylistDelegateProtocol = ObjectGraph.playlistDelegate
    
    // Delegate that retrieves current playback info
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    private lazy var layoutManager: LayoutManager = ObjectGraph.layoutManager
    
    private lazy var gapsEditor: ModalDialogDelegate = WindowFactory.getGapsEditorDialog()
    private lazy var delayedPlaybackEditor: ModalDialogDelegate = WindowFactory.getDelayedPlaybackEditorDialog()
    
    private lazy var alertDialog: AlertWindowController = AlertWindowController.instance
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        theMenu.enableIf(layoutManager.isShowingPlaylist())
        
        if (!theMenu.isEnabled) {
            return
        }
        
        let playlistSize = playlist.size
        let playlistNotEmpty = playlistSize > 0
        let atLeastOneItemSelected = PlaylistViewState.currentView.selectedRow >= 0
        let numSelectedRows = PlaylistViewState.currentView.numberOfSelectedRows
        
        // These menu items require 1 - the playlist to be visible, and 2 - at least one playlist item to be selected
        let showingDialogOrPopover = NSApp.modalWindow != nil || WindowState.showingPopover
        [moveItemsUpMenuItem, moveItemsToTopMenuItem, moveItemsDownMenuItem, moveItemsToBottomMenuItem, removeSelectedItemsMenuItem].forEach({$0?.enableIf(!showingDialogOrPopover && atLeastOneItemSelected)})
        
        playSelectedItemMenuItem.enableIf(!showingDialogOrPopover && numSelectedRows == 1)
        playSelectedItemDelayedMenuItem.enableIf(numSelectedRows == 1)
        
        if numSelectedRows == 1 && !areOnlyGroupsSelected() && playbackInfo.state == .transcoding && (selectedTrack() == playbackInfo.playingTrack?.track) {
            playSelectedItemMenuItem.disable()
            playSelectedItemDelayedMenuItem.disable()
        }
        
        // These menu items require 1 - the playlist to be visible, and 2 - at least one track in the playlist
        [searchPlaylistMenuItem, sortPlaylistMenuItem, scrollToTopMenuItem, scrollToBottomMenuItem, pageUpMenuItem, pageDownMenuItem, savePlaylistMenuItem, clearPlaylistMenuItem, invertSelectionMenuItem].forEach({$0?.enableIf(playlistNotEmpty)})
        
        // At least 2 tracks needed for these functions, and at least one track selected
        [moveItemsToTopMenuItem, moveItemsToBottomMenuItem, cropSelectionMenuItem].forEach({$0?.enableIf(playlistSize > 1 && atLeastOneItemSelected)})
        
        clearSelectionMenuItem.enableIf(playlistNotEmpty && atLeastOneItemSelected)
        
        expandSelectedGroupsMenuItem.enableIf(atLeastOneItemSelected && areOnlyGroupsSelected())
        collapseSelectedItemsMenuItem.enableIf(atLeastOneItemSelected)
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        
        if (!theMenu.isEnabled) {
            return
        }
        
        let playlistNotEmpty = playlist.size > 0
        let numSelectedRows = PlaylistViewState.currentView.numberOfSelectedRows
        
        // Make sure it's a track, not a group, and that only one track is selected
        if numSelectedRows == 1 {
            
            if PlaylistViewState.selectedItem.type != .group {
                
                let track = selectedTrack()
                
                let gaps = playlist.getGapsAroundTrack(track)
                insertGapsMenuItem.hideIf_elseShow(gaps.hasGaps)
                removeGapsMenuItem.showIf_elseHide(gaps.hasGaps)
                editGapsMenuItem.showIf_elseHide(gaps.hasGaps)
                
            } else {
                [insertGapsMenuItem, removeGapsMenuItem, editGapsMenuItem].forEach({$0?.hide()})
            }
            
        } else {
            [insertGapsMenuItem, removeGapsMenuItem, editGapsMenuItem].forEach({$0?.hide()})
        }
        
        expandSelectedGroupsMenuItem.hideIf_elseShow(PlaylistViewState.current == .tracks)
        collapseSelectedItemsMenuItem.hideIf_elseShow(PlaylistViewState.current == .tracks)
        
        [expandAllGroupsMenuItem, collapseAllGroupsMenuItem].forEach({$0.hideIf_elseShow(!(PlaylistViewState.current != .tracks && playlistNotEmpty))})
    }
    
    private func areOnlyGroupsSelected() -> Bool {
        
        let items = PlaylistViewState.selectedItems
        
        for item in items {
            if item.type != .group {
                return false
            }
        }
        
        return true
    }
    
    // Assumes only one item selected, and that it's a track
    private func selectedTrack() -> Track {
        let selItem = PlaylistViewState.selectedItem
        return selItem.type == .index ? playlist.trackAtIndex(selItem.index!)!.track : selItem.track!
    }
    
    // Invokes the Open file dialog, to allow the user to add tracks/playlists to the app playlist
    @IBAction func addFilesAction(_ sender: Any) {
        
        if playlist.isBeingModified {
            
            alertDialog.showAlert(.error, "Playlist not modified", "The playlist cannot be modified while tracks are being added", "Please wait till the playlist is done adding tracks ...")
            return
        }
        
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.addTracks, nil))
    }
    
    // Removes any selected playlist items from the playlist
    @IBAction func removeSelectedItemsAction(_ sender: Any) {
        
        if playlist.isBeingModified {
            
            alertDialog.showAlert(.error, "Playlist not modified", "The playlist cannot be modified while tracks are being added", "Please wait till the playlist is done adding tracks ...")
            return
        }
        
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.removeTracks, PlaylistViewState.current))
        sequenceChanged()
    }
    
    // Invokes the Save file dialog, to allow the user to save all playlist items to a playlist file
    @IBAction func savePlaylistAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.savePlaylist, nil))
    }
    
    // Removes all items from the playlist
    @IBAction func clearPlaylistAction(_ sender: Any) {
        
        if playlist.isBeingModified {
            
            alertDialog.showAlert(.error, "Playlist not modified", "The playlist cannot be modified while tracks are being added", "Please wait till the playlist is done adding tracks ...")
            return
        }
        
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.clearPlaylist, nil))
    }
    
    // Moves any selected playlist items up one row in the playlist
    @IBAction func moveItemsUpAction(_ sender: Any) {
        
        if playlist.isBeingModified {
            
            alertDialog.showAlert(.error, "Playlist not modified", "The playlist cannot be modified while tracks are being added", "Please wait till the playlist is done adding tracks ...")
            return
        }
        
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.moveTracksUp, PlaylistViewState.current))
        sequenceChanged()
    }
    
    // Moves the selected playlist item up one row in the playlist
    @IBAction func moveItemsToTopAction(_ sender: Any) {
        
        if playlist.isBeingModified {
            
            alertDialog.showAlert(.error, "Playlist not modified", "The playlist cannot be modified while tracks are being added", "Please wait till the playlist is done adding tracks ...")
            return
        }
        
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.moveTracksToTop, PlaylistViewState.current))
        sequenceChanged()
    }
    
    // Moves any selected playlist items down one row in the playlist
    @IBAction func moveItemsDownAction(_ sender: Any) {
        
        if playlist.isBeingModified {
            
            alertDialog.showAlert(.error, "Playlist not modified", "The playlist cannot be modified while tracks are being added", "Please wait till the playlist is done adding tracks ...")
            return
        }
        
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.moveTracksDown, PlaylistViewState.current))
        sequenceChanged()
    }
    
    // Moves the selected playlist item up one row in the playlist
    @IBAction func moveItemsToBottomAction(_ sender: Any) {
        
        if playlist.isBeingModified {
            
            alertDialog.showAlert(.error, "Playlist not modified", "The playlist cannot be modified while tracks are being added", "Please wait till the playlist is done adding tracks ...")
            return
        }
        
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.moveTracksToBottom, PlaylistViewState.current))
        sequenceChanged()
    }
    
    @IBAction func insertGapsAction(_ sender: NSMenuItem) {
        
        if playlist.isBeingModified {
            
            alertDialog.showAlert(.error, "Playlist not modified", "The playlist cannot be modified while tracks are being added", "Please wait till the playlist is done adding tracks ...")
            return
        }
        
        // Sender's tag is gap duration in seconds
        let tag = sender.tag
        
        if tag != 0 {
            
            // Negative tag value indicates .beforeTrack, positive value indicates .afterTrack
            let gapPosn: PlaybackGapPosition = tag < 0 ? .beforeTrack: .afterTrack
            let gap = PlaybackGap(Double(abs(tag)), gapPosn)
            
            let gapBefore = gapPosn == .beforeTrack ? gap : nil
            let gapAfter = gapPosn == .afterTrack ? gap : nil
            
            SyncMessenger.publishActionMessage(InsertPlaybackGapsActionMessage(gapBefore, gapAfter, PlaylistViewState.current))
            
        } else {
            
            // Custom gap dialog
            gapsEditor.setDataForKey("gaps", nil)
            
            _ = gapsEditor.showDialog()
        }
    }
    
    @IBAction func editGapsAction(_ sender: NSMenuItem) {
        
        if playlist.isBeingModified {
            
            alertDialog.showAlert(.error, "Playlist not modified", "The playlist cannot be modified while tracks are being added", "Please wait till the playlist is done adding tracks ...")
            return
        }
        
        // Custom gap dialog
        let gaps = playlist.getGapsAroundTrack(selectedTrack())
        
        gapsEditor.setDataForKey("gaps", gaps)
        
        _ = gapsEditor.showDialog()
    }
    
    @IBAction func removeGapsAction(_ sender: NSMenuItem) {
        
        if playlist.isBeingModified {
            
            alertDialog.showAlert(.error, "Playlist not modified", "The playlist cannot be modified while tracks are being added", "Please wait till the playlist is done adding tracks ...")
            return
        }
        
        SyncMessenger.publishActionMessage(RemovePlaybackGapsActionMessage(PlaylistViewState.current))
    }
    
    // Presents the search modal dialog to allow the user to search for playlist tracks
    @IBAction func playlistSearchAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.search, nil))
    }
    
    // Presents the sort modal dialog to allow the user to sort playlist tracks
    @IBAction func playlistSortAction(_ sender: Any) {
        
        if playlist.isBeingModified {
            
            alertDialog.showAlert(.error, "Playlist not modified", "The playlist cannot be modified while tracks are being added", "Please wait till the playlist is done adding tracks ...")
            return
        }
        
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.sort, nil))
    }
    
    // Plays the selected playlist item (track or group)
    @IBAction func playSelectedItemAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.playSelectedItem, PlaylistViewState.current))
    }
    
    @IBAction func playSelectedItemAfterDelayAction(_ sender: NSMenuItem) {
        
        let delay = sender.tag
        
        if delay == 0 {
            
            // Custom delay ... show dialog
            _ = delayedPlaybackEditor.showDialog()
            
        } else {
            
            SyncMessenger.publishActionMessage(DelayedPlaybackActionMessage(Double(delay), PlaylistViewState.current))
        }
    }
    
    @IBAction func clearSelectionAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.clearSelection, PlaylistViewState.current))
    }
    
    @IBAction func invertSelectionAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.invertSelection, PlaylistViewState.current))
    }
    
    @IBAction func cropSelectionAction(_ sender: Any) {
        
        if playlist.isBeingModified {
            
            alertDialog.showAlert(.error, "Playlist not modified", "The playlist cannot be modified while tracks are being added", "Please wait till the playlist is done adding tracks ...")
            return
        }
        
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.cropSelection, PlaylistViewState.current))
        sequenceChanged()
    }
    
    @IBAction func expandSelectedGroupsAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.expandSelectedGroups, PlaylistViewState.current))
    }
    
    @IBAction func collapseSelectedItemsAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.collapseSelectedItems, PlaylistViewState.current))
    }
    
    @IBAction func expandAllGroupsAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.expandAllGroups, PlaylistViewState.current))
    }
    
    @IBAction func collapseAllGroupsAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.collapseAllGroups, PlaylistViewState.current))
    }
    
    // Scrolls the current playlist view to the very top
    @IBAction func scrollToTopAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.scrollToTop, PlaylistViewState.current))
    }
    
    // Scrolls the current playlist view to the very bottom
    @IBAction func scrollToBottomAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.scrollToBottom, PlaylistViewState.current))
    }
    
    @IBAction func pageUpAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.pageUp, PlaylistViewState.current))
    }
    @IBAction func pageDownAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.pageDown, PlaylistViewState.current))
    }
    
    // Publishes a notification that the playback sequence may have changed, so that interested UI observers may update their views if necessary
    private func sequenceChanged() {
        if (playbackInfo.playingTrack != nil) {
            SyncMessenger.publishNotification(SequenceChangedNotification.instance)
        }
    }
}
