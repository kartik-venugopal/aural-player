import Cocoa

/*
 Provides actions for the Playlist menu that perform various CRUD (model) operations and view navigation operations on the playlist.
 
 NOTE - No actions are directly handled by this class. Action messages are published to another app component that is responsible for these functions.
 */
class PlaylistMenuController: NSObject, NSMenuDelegate {
    
    @IBOutlet weak var theMenu: NSMenuItem!
    
    @IBOutlet weak var playSelectedItemMenuItem: NSMenuItem!
    @IBOutlet weak var moveItemsUpMenuItem: NSMenuItem!
    @IBOutlet weak var moveItemsToTopMenuItem: NSMenuItem!
    @IBOutlet weak var moveItemsDownMenuItem: NSMenuItem!
    @IBOutlet weak var removeSelectedItemsMenuItem: NSMenuItem!
    
    @IBOutlet weak var insertGapsMenuItem: NSMenuItem!
    @IBOutlet weak var editGapsMenuItem: NSMenuItem!
    @IBOutlet weak var removeGapsMenuItem: NSMenuItem!
    
    @IBOutlet weak var invertSelectionMenuItem: NSMenuItem!
    @IBOutlet weak var cropSelectionMenuItem: NSMenuItem!
    
    @IBOutlet weak var savePlaylistMenuItem: NSMenuItem!
    @IBOutlet weak var clearPlaylistMenuItem: NSMenuItem!
    @IBOutlet weak var searchPlaylistMenuItem: NSMenuItem!
    @IBOutlet weak var sortPlaylistMenuItem: NSMenuItem!
    @IBOutlet weak var scrollToTopMenuItem: NSMenuItem!
    @IBOutlet weak var scrollToBottomMenuItem: NSMenuItem!
    
    private let playlist: PlaylistAccessorDelegateProtocol = ObjectGraph.getPlaylistAccessorDelegate()
    
    // Delegate that retrieves current playback info
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.getPlaybackInfoDelegate()
    
    private lazy var layoutManager: LayoutManager = ObjectGraph.getLayoutManager()
    
    private lazy var gapsEditor: ModalDialogDelegate = WindowFactory.getGapsEditorDialog()
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        theMenu.isEnabled = AppModeManager.mode == .regular && layoutManager.isShowingPlaylist()
        
        if (AppModeManager.mode != .regular) {
            return
        }
        
        // These menu items require 1 - the playlist to be visible, and 2 - at least one playlist item to be selected
        let showingDialogOrPopover = NSApp.modalWindow != nil || WindowState.showingPopover
        [playSelectedItemMenuItem, moveItemsUpMenuItem, moveItemsToTopMenuItem, moveItemsDownMenuItem, removeSelectedItemsMenuItem].forEach({$0?.isEnabled = layoutManager.isShowingPlaylist() && !showingDialogOrPopover && PlaylistViewState.currentView.selectedRow >= 0})
        
        // These menu items require 1 - the playlist to be visible, and 2 - at least one track in the playlist
        [searchPlaylistMenuItem, sortPlaylistMenuItem, scrollToTopMenuItem, scrollToBottomMenuItem, savePlaylistMenuItem, clearPlaylistMenuItem, invertSelectionMenuItem].forEach({$0?.isEnabled = layoutManager.isShowingPlaylist() && playlist.size() > 0})
        
        // At least 2 tracks needed for these functions, and at least one track selected
        cropSelectionMenuItem.isEnabled = layoutManager.isShowingPlaylist() && playlist.size() > 1 && PlaylistViewState.currentView.selectedRow >= 0
        
        if PlaylistViewState.currentView.selectedRowIndexes.count == 1 {
            
            if let track = selectedTrack() {
                
                let gaps = playlist.getGapsAroundTrack(track)
                insertGapsMenuItem.isHidden = gaps.hasGaps
                removeGapsMenuItem.isHidden = !gaps.hasGaps
                editGapsMenuItem.isHidden = !gaps.hasGaps
                
            } else {
                
                [insertGapsMenuItem, removeGapsMenuItem, editGapsMenuItem].forEach({$0?.isHidden = true})
            }
            
        } else {
            
            [insertGapsMenuItem, removeGapsMenuItem, editGapsMenuItem].forEach({$0?.isHidden = true})
        }
    }

    private func selectedTrack() -> Track? {
        
        let selRow = PlaylistViewState.currentView.selectedRow
        
        if selRow >= 0 {
            
            let track = playlist.trackAtIndex(selRow)
            return track!.track
        }
        
        return nil
    }
    
    // Invokes the Open file dialog, to allow the user to add tracks/playlists to the app playlist
    @IBAction func addFilesAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.addTracks, nil))
    }
    
    // Removes any selected playlist items from the playlist
    @IBAction func removeSelectedItemsAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.removeTracks, PlaylistViewState.current))
        sequenceChanged()
    }
    
    // Invokes the Save file dialog, to allow the user to save all playlist items to a playlist file
    @IBAction func savePlaylistAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.savePlaylist, nil))
    }
    
    // Removes all items from the playlist
    @IBAction func clearPlaylistAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.clearPlaylist, nil))
    }
    
    // Moves any selected playlist items up one row in the playlist
    @IBAction func moveItemsUpAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.moveTracksUp, PlaylistViewState.current))
        sequenceChanged()
    }
    
    // Moves the selected playlist item up one row in the playlist
    @IBAction func moveItemsToTopAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.moveTracksToTop, PlaylistViewState.current))
        sequenceChanged()
    }
    
    // Moves any selected playlist items down one row in the playlist
    @IBAction func moveItemsDownAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.moveTracksDown, PlaylistViewState.current))
        sequenceChanged()
    }
    
    @IBAction func insertGapsAction(_ sender: NSMenuItem) {
        
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
            gapsEditor.setDataForKey("track", selectedTrack()!)
            gapsEditor.setDataForKey("gaps", nil)
            
            _ = gapsEditor.showDialog()
        }
    }
    
    @IBAction func editGapsAction(_ sender: NSMenuItem) {
        
        // Custom gap dialog
        let gaps = playlist.getGapsAroundTrack(selectedTrack()!)
        
        gapsEditor.setDataForKey("gaps", gaps)
        
        _ = gapsEditor.showDialog()
    }
    
    @IBAction func removeGapsAction(_ sender: NSMenuItem) {
        SyncMessenger.publishActionMessage(RemovePlaybackGapsActionMessage(PlaylistViewState.current))
    }
    
    // Presents the search modal dialog to allow the user to search for playlist tracks
    @IBAction func playlistSearchAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.search, nil))
    }
    
    // Presents the sort modal dialog to allow the user to sort playlist tracks
    @IBAction func playlistSortAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.sort, nil))
    }
    
    // Plays the selected playlist item (track or group)
    @IBAction func playSelectedItemAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.playSelectedItem, PlaylistViewState.current))
    }
    
    @IBAction func invertSelectionAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.invertSelection, PlaylistViewState.current))
    }
    
    @IBAction func cropSelectionAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.cropSelection, PlaylistViewState.current))
        sequenceChanged()
    }
    
    // Scrolls the current playlist view to the very top
    @IBAction func scrollToTopAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.scrollToTop, PlaylistViewState.current))
    }
    
    // Scrolls the current playlist view to the very bottom
    @IBAction func scrollToBottomAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.scrollToBottom, PlaylistViewState.current))
    }
    
    // Publishes a notification that the playback sequence may have changed, so that interested UI observers may update their views if necessary
    private func sequenceChanged() {
        if (playbackInfo.getPlayingTrack() != nil) {
            SyncMessenger.publishNotification(SequenceChangedNotification.instance)
        }
    }
}
