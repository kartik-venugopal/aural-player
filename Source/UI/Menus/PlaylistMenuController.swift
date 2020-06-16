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
    @IBOutlet weak var previousViewMenuItem: NSMenuItem!
    @IBOutlet weak var nextViewMenuItem: NSMenuItem!
    
    private let playlist: PlaylistDelegateProtocol = ObjectGraph.playlistDelegate
    
    // Delegate that retrieves current playback info
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    private lazy var gapsEditor: ModalDialogDelegate = WindowFactory.gapsEditorDialog
    private lazy var delayedPlaybackEditor: ModalDialogDelegate = WindowFactory.delayedPlaybackEditorDialog
    
    private lazy var alertDialog: AlertWindowController = WindowFactory.alertWindowController
    
    func menuNeedsUpdate(_ menu: NSMenu) {

        let showingModalComponent = WindowManager.isShowingModalComponent
        
        if WindowManager.isChaptersListWindowKey {
            
            // If the chapters list window is key, most playlist menu items need to be disabled
            menu.items.forEach({$0.disable()})
            
            // Allow playing of selected item (chapter) if the chapters list is not modal (i.e. performing a search) and an item is selected
            let hasPlayableChapter: Bool = !showingModalComponent && PlaylistViewState.hasSelectedChapter
            
            playSelectedItemMenuItem.enableIf(hasPlayableChapter)
            theMenu.enableIf(hasPlayableChapter)
            
            // Since all items but one have been disabled, nothing further to do
            return
            
        } else {
            
            // Re-enabled items that may have been disabled before
            menu.items.forEach({$0.enable()})
        }
        
        theMenu.enableIf(WindowManager.isShowingPlaylist)
        
        if theMenu.isDisabled {
            return
        }
        
        // TODO: Revisit the below item enabling code (esp. the ones relying on no modal window). How to display modal windows so as to avoid
        // this dirty logic ???
        
        let playlistSize = playlist.size
        let playlistNotEmpty = playlistSize > 0
        let atLeastOneItemSelected = PlaylistViewState.currentView.selectedRow >= 0
        let numSelectedRows = PlaylistViewState.currentView.numberOfSelectedRows
        
        // These menu items require 1 - the playlist to be visible, and 2 - at least one playlist item to be selected
        
        [moveItemsUpMenuItem, moveItemsToTopMenuItem, moveItemsDownMenuItem, moveItemsToBottomMenuItem, removeSelectedItemsMenuItem].forEach({$0?.enableIf(!showingModalComponent && atLeastOneItemSelected)})
        
        [previousViewMenuItem, nextViewMenuItem].forEach({$0?.enableIf(!showingModalComponent)})
        
        playSelectedItemMenuItem.enableIf(!showingModalComponent && numSelectedRows == 1)
        playSelectedItemDelayedMenuItem.enableIf(numSelectedRows == 1)
        
        let onlyGroupsSelected: Bool = areOnlyGroupsSelected
        
        if numSelectedRows == 1 && !onlyGroupsSelected && selectedTrack == playbackInfo.transcodingTrack {
            playSelectedItemMenuItem.disable()
            playSelectedItemDelayedMenuItem.disable()
        }
        
        // These menu items require 1 - the playlist to be visible, and 2 - at least one track in the playlist
        [searchPlaylistMenuItem, sortPlaylistMenuItem, scrollToTopMenuItem, scrollToBottomMenuItem, pageUpMenuItem, pageDownMenuItem, savePlaylistMenuItem, clearPlaylistMenuItem, invertSelectionMenuItem].forEach({$0?.enableIf(playlistNotEmpty)})
        
        // At least 2 tracks needed for these functions, and at least one track selected
        [moveItemsToTopMenuItem, moveItemsToBottomMenuItem, cropSelectionMenuItem].forEach({$0?.enableIf(playlistSize > 1 && atLeastOneItemSelected)})
        
        clearSelectionMenuItem.enableIf(playlistNotEmpty && atLeastOneItemSelected)
        
        expandSelectedGroupsMenuItem.enableIf(PlaylistViewState.current != .tracks && atLeastOneItemSelected && onlyGroupsSelected)
        collapseSelectedItemsMenuItem.enableIf(PlaylistViewState.current != .tracks && atLeastOneItemSelected)
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        
        if theMenu.isDisabled {
            return
        }
        
        let playlistNotEmpty = playlist.size > 0
        let numSelectedRows = PlaylistViewState.currentView.numberOfSelectedRows
        
        // Make sure it's a track, not a group, and that only one track is selected
        if numSelectedRows == 1 {
            
            if PlaylistViewState.selectedItem.type != .group {
                
                let gaps = playlist.getGapsAroundTrack(selectedTrack)
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
    
    private var areOnlyGroupsSelected: Bool {
        
        let items = PlaylistViewState.selectedItems
        
        for item in items {
            if item.type != .group {
                return false
            }
        }
        
        return true
    }
    
    // Assumes only one item selected, and that it's a track
    private var selectedTrack: Track {
        
        let selItem = PlaylistViewState.selectedItem
        return selItem.type == .index ? playlist.trackAtIndex(selItem.index!)!.track : selItem.track!
    }
    
    // Invokes the Open file dialog, to allow the user to add tracks/playlists to the app playlist
    @IBAction func addFilesAction(_ sender: Any) {
        
        if playlist.isBeingModified {
            
            alertDialog.showAlert(.error, "Playlist not modified", "The playlist cannot be modified while tracks are being added", "Please wait till the playlist is done adding tracks ...")
            return
        }
        
        Messenger.publish(.playlist_addTracks)
    }
    
    // Removes any selected playlist items from the playlist
    @IBAction func removeSelectedItemsAction(_ sender: Any) {
        
        if playlist.isBeingModified {
            
            alertDialog.showAlert(.error, "Playlist not modified", "The playlist cannot be modified while tracks are being added", "Please wait till the playlist is done adding tracks ...")
            return
        }
        
        Messenger.publish(.playlist_removeTracks, payload: PlaylistViewSelector.forView(PlaylistViewState.current))
//        sequenceChanged()
    }
    
    // Invokes the Save file dialog, to allow the user to save all playlist items to a playlist file
    @IBAction func savePlaylistAction(_ sender: Any) {
        Messenger.publish(.playlist_savePlaylist)
    }
    
    // Removes all items from the playlist
    @IBAction func clearPlaylistAction(_ sender: Any) {
        
        if playlist.isBeingModified {
            
            alertDialog.showAlert(.error, "Playlist not modified", "The playlist cannot be modified while tracks are being added", "Please wait till the playlist is done adding tracks ...")
            return
        }
        
        Messenger.publish(.playlist_clearPlaylist)
    }
    
    // Moves any selected playlist items up one row in the playlist
    @IBAction func moveItemsUpAction(_ sender: Any) {
        
        if playlist.isBeingModified {
            
            alertDialog.showAlert(.error, "Playlist not modified", "The playlist cannot be modified while tracks are being added", "Please wait till the playlist is done adding tracks ...")
            return
        }
        
        Messenger.publish(.playlist_moveTracksUp, payload: PlaylistViewSelector.forView(PlaylistViewState.current))
//        sequenceChanged()
    }
    
    // Moves the selected playlist item up one row in the playlist
    @IBAction func moveItemsToTopAction(_ sender: Any) {
        
        if playlist.isBeingModified {
            
            alertDialog.showAlert(.error, "Playlist not modified", "The playlist cannot be modified while tracks are being added", "Please wait till the playlist is done adding tracks ...")
            return
        }
        
        Messenger.publish(.playlist_moveTracksToTop, payload: PlaylistViewSelector.forView(PlaylistViewState.current))
//        sequenceChanged()
    }
    
    // Moves any selected playlist items down one row in the playlist
    @IBAction func moveItemsDownAction(_ sender: Any) {
        
        if playlist.isBeingModified {
            
            alertDialog.showAlert(.error, "Playlist not modified", "The playlist cannot be modified while tracks are being added", "Please wait till the playlist is done adding tracks ...")
            return
        }
        
        Messenger.publish(.playlist_moveTracksDown, payload: PlaylistViewSelector.forView(PlaylistViewState.current))
//        sequenceChanged()
    }
    
    // Moves the selected playlist item up one row in the playlist
    @IBAction func moveItemsToBottomAction(_ sender: Any) {
        
        if playlist.isBeingModified {
            
            alertDialog.showAlert(.error, "Playlist not modified", "The playlist cannot be modified while tracks are being added", "Please wait till the playlist is done adding tracks ...")
            return
        }
        
        Messenger.publish(.playlist_moveTracksToBottom, payload: PlaylistViewSelector.forView(PlaylistViewState.current))
//        sequenceChanged()
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
            
            Messenger.publish(InsertPlaybackGapsCommandNotification(gapBeforeTrack: gapBefore, gapAfterTrack: gapAfter,
                                                                    viewSelector: PlaylistViewSelector.forView(PlaylistViewState.current)))
            
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
        let gaps = playlist.getGapsAroundTrack(selectedTrack)
        
        gapsEditor.setDataForKey("gaps", gaps)
        
        _ = gapsEditor.showDialog()
    }
    
    @IBAction func removeGapsAction(_ sender: NSMenuItem) {
        
        if playlist.isBeingModified {
            
            alertDialog.showAlert(.error, "Playlist not modified", "The playlist cannot be modified while tracks are being added", "Please wait till the playlist is done adding tracks ...")
            return
        }
        
        Messenger.publish(.playlist_removeGaps, payload: PlaylistViewSelector.forView(PlaylistViewState.current))
    }
    
    // Presents the search modal dialog to allow the user to search for playlist tracks
    @IBAction func playlistSearchAction(_ sender: Any) {
        Messenger.publish(.playlist_search)
    }
    
    // Presents the sort modal dialog to allow the user to sort playlist tracks
    @IBAction func playlistSortAction(_ sender: Any) {
        
        if playlist.isBeingModified {
            
            alertDialog.showAlert(.error, "Playlist not modified", "The playlist cannot be modified while tracks are being added", "Please wait till the playlist is done adding tracks ...")
            return
        }
        
        Messenger.publish(.playlist_sort)
    }
    
    // Plays the selected playlist item (track or group)
    @IBAction func playSelectedItemAction(_ sender: Any) {
        
        if WindowManager.isChaptersListWindowKey {
            
            SyncMessenger.publishActionMessage(PlaylistActionMessage(.playSelectedChapter, nil))
            
        } else {

            Messenger.publish(.playlist_playSelectedItem, payload: PlaylistViewSelector.forView(PlaylistViewState.current))
        }
    }
    
    @IBAction func playSelectedItemAfterDelayAction(_ sender: NSMenuItem) {
        
        let delay = sender.tag
        
        if delay == 0 {
            
            // Custom delay ... show dialog
            _ = delayedPlaybackEditor.showDialog()
            
        } else {
            
            Messenger.publish(DelayedPlaybackCommandNotification(delay: Double(delay),
                                                                 viewSelector: PlaylistViewSelector.forView(PlaylistViewState.current)))
        }
    }
    
    @IBAction func clearSelectionAction(_ sender: Any) {
        Messenger.publish(.playlist_clearSelection, payload: PlaylistViewSelector.forView(PlaylistViewState.current))
    }
    
    @IBAction func invertSelectionAction(_ sender: Any) {
        Messenger.publish(.playlist_invertSelection, payload: PlaylistViewSelector.forView(PlaylistViewState.current))
    }
    
    @IBAction func cropSelectionAction(_ sender: Any) {
        
        if playlist.isBeingModified {
            
            alertDialog.showAlert(.error, "Playlist not modified", "The playlist cannot be modified while tracks are being added", "Please wait till the playlist is done adding tracks ...")
            return
        }
        
        Messenger.publish(.playlist_cropSelection, payload: PlaylistViewSelector.forView(PlaylistViewState.current))
//        sequenceChanged()
    }
    
    @IBAction func expandSelectedGroupsAction(_ sender: Any) {
        Messenger.publish(.playlist_expandSelectedGroups, payload: PlaylistViewSelector.forView(PlaylistViewState.current))
    }
    
    @IBAction func collapseSelectedItemsAction(_ sender: Any) {
        Messenger.publish(.playlist_collapseSelectedItems, payload: PlaylistViewSelector.forView(PlaylistViewState.current))
    }
    
    @IBAction func expandAllGroupsAction(_ sender: Any) {
        Messenger.publish(.playlist_expandAllGroups, payload: PlaylistViewSelector.forView(PlaylistViewState.current))
    }
    
    @IBAction func collapseAllGroupsAction(_ sender: Any) {
        Messenger.publish(.playlist_collapseAllGroups, payload: PlaylistViewSelector.forView(PlaylistViewState.current))
    }
    
    // Scrolls the current playlist view to the very top
    @IBAction func scrollToTopAction(_ sender: Any) {
        Messenger.publish(.playlist_scrollToTop, payload: PlaylistViewSelector.forView(PlaylistViewState.current))
    }
    
    // Scrolls the current playlist view to the very bottom
    @IBAction func scrollToBottomAction(_ sender: Any) {
        Messenger.publish(.playlist_scrollToBottom, payload: PlaylistViewSelector.forView(PlaylistViewState.current))
    }
    
    @IBAction func pageUpAction(_ sender: Any) {
        Messenger.publish(.playlist_pageUp, payload: PlaylistViewSelector.forView(PlaylistViewState.current))
    }
    @IBAction func pageDownAction(_ sender: Any) {
        Messenger.publish(.playlist_pageDown, payload: PlaylistViewSelector.forView(PlaylistViewState.current))
    }
    
    @IBAction func previousPlaylistViewAction(_ sender: Any) {
        Messenger.publish(.playlist_previousView)
    }
    
    @IBAction func nextPlaylistViewAction(_ sender: Any) {
        Messenger.publish(.playlist_nextView)
    }
    
    // Publishes a notification that the playback sequence may have changed, so that interested UI observers may update their views if necessary
//    private func sequenceChanged() {
//        
//        if playbackInfo.currentTrack != nil {
//            SyncMessenger.publishNotification(SequenceChangedNotification.instance)
//        }
//    }
}
