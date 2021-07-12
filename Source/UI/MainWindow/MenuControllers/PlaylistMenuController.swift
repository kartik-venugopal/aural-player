//
//  PlaylistMenuController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
 Provides actions for the Playlist menu that perform various CRUD (model) operations and view navigation operations on the playlist.
 
 NOTE - No actions are directly handled by this class. Command notifications are published to another app component that is responsible for these functions.
 */
class PlaylistMenuController: NSObject, NSMenuDelegate {
    
    @IBOutlet weak var theMenu: NSMenuItem!
    
    @IBOutlet weak var playSelectedItemMenuItem: NSMenuItem!
    
    @IBOutlet weak var moveItemsUpMenuItem: NSMenuItem!
    @IBOutlet weak var moveItemsToTopMenuItem: NSMenuItem!
    @IBOutlet weak var moveItemsDownMenuItem: NSMenuItem!
    @IBOutlet weak var moveItemsToBottomMenuItem: NSMenuItem!
    @IBOutlet weak var removeSelectedItemsMenuItem: NSMenuItem!
    
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
    
    private lazy var alertDialog: AlertWindowController = AlertWindowController.instance
    
    private lazy var messenger = Messenger(for: self)
    
    func menuNeedsUpdate(_ menu: NSMenu) {

        let showingModalComponent = WindowManager.instance.isShowingModalComponent
        
        if WindowManager.instance.isChaptersListWindowKey {
            
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
        
        theMenu.enableIf(WindowManager.instance.isShowingPlaylist)
        if theMenu.isDisabled {return}
        
        // TODO: Revisit the below item enabling code (esp. the ones relying on no modal window). How to display modal windows so as to avoid
        // this dirty logic ???
        
        let playlistSize = playlist.size
        let playlistNotEmpty = playlistSize > 0
        
        let numSelectedRows = PlaylistViewState.selectedItemCount
        let atLeastOneItemSelected = numSelectedRows > 0
        
        // These menu items require 1 - the playlist to be visible, and 2 - at least one playlist item to be selected
        
        [moveItemsUpMenuItem, moveItemsToTopMenuItem, moveItemsDownMenuItem, moveItemsToBottomMenuItem, removeSelectedItemsMenuItem].forEach({$0?.enableIf(!showingModalComponent && atLeastOneItemSelected)})
        
        [previousViewMenuItem, nextViewMenuItem].forEach({$0?.enableIf(!showingModalComponent)})
        
        playSelectedItemMenuItem.enableIf(!showingModalComponent && numSelectedRows == 1)
        
        let onlyGroupsSelected: Bool = areOnlyGroupsSelected
        
        // These menu items require 1 - the playlist to be visible, and 2 - at least one track in the playlist
        [searchPlaylistMenuItem, sortPlaylistMenuItem, scrollToTopMenuItem, scrollToBottomMenuItem, pageUpMenuItem, pageDownMenuItem, savePlaylistMenuItem, clearPlaylistMenuItem, invertSelectionMenuItem].forEach({$0?.enableIf(playlistNotEmpty)})
        
        // At least 2 tracks needed for these functions, and at least one track selected
        [moveItemsToTopMenuItem, moveItemsToBottomMenuItem, cropSelectionMenuItem].forEach({$0?.enableIf(playlistSize > 1 && atLeastOneItemSelected)})
        
        clearSelectionMenuItem.enableIf(playlistNotEmpty && atLeastOneItemSelected)
        
        expandSelectedGroupsMenuItem.enableIf(PlaylistViewState.currentView != .tracks && atLeastOneItemSelected && onlyGroupsSelected)
        collapseSelectedItemsMenuItem.enableIf(PlaylistViewState.currentView != .tracks && atLeastOneItemSelected)
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        
        if theMenu.isDisabled {return}
        
        let playlistNotEmpty = playlist.size > 0
        
        expandSelectedGroupsMenuItem.hideIf(PlaylistViewState.currentView == .tracks)
        collapseSelectedItemsMenuItem.hideIf(PlaylistViewState.currentView == .tracks)
        
        [expandAllGroupsMenuItem, collapseAllGroupsMenuItem].forEach({$0.hideIf(!(PlaylistViewState.currentView != .tracks && playlistNotEmpty))})
    }
    
    private var areOnlyGroupsSelected: Bool {!PlaylistViewState.selectedItems.contains(where: {$0.type != .group})}
    
    // Invokes the Open file dialog, to allow the user to add tracks/playlists to the app playlist
    @IBAction func addFilesAction(_ sender: Any) {
        
        if !checkIfPlaylistIsBeingModified() {
            messenger.publish(.playlist_addTracks)
        }
    }
    
    // Removes any selected playlist items from the playlist
    @IBAction func removeSelectedItemsAction(_ sender: Any) {
        
        if !checkIfPlaylistIsBeingModified() {
            messenger.publish(.playlist_removeTracks, payload: PlaylistViewState.currentViewSelector)
        }
    }
    
    // Invokes the Save file dialog, to allow the user to save all playlist items to a playlist file
    @IBAction func savePlaylistAction(_ sender: Any) {
        messenger.publish(.playlist_savePlaylist)
    }
    
    // Removes all items from the playlist
    @IBAction func clearPlaylistAction(_ sender: Any) {
        
        if !checkIfPlaylistIsBeingModified() {
            messenger.publish(.playlist_clearPlaylist)
        }
    }
    
    // Moves any selected playlist items up one row in the playlist
    @IBAction func moveItemsUpAction(_ sender: Any) {
        
        if !checkIfPlaylistIsBeingModified() {
            messenger.publish(.playlist_moveTracksUp, payload: PlaylistViewState.currentViewSelector)
        }
    }
    
    // Moves the selected playlist item up one row in the playlist
    @IBAction func moveItemsToTopAction(_ sender: Any) {
        
        if !checkIfPlaylistIsBeingModified() {
            messenger.publish(.playlist_moveTracksToTop, payload: PlaylistViewState.currentViewSelector)
        }
    }
    
    // Moves any selected playlist items down one row in the playlist
    @IBAction func moveItemsDownAction(_ sender: Any) {
        
        if !checkIfPlaylistIsBeingModified() {
            messenger.publish(.playlist_moveTracksDown, payload: PlaylistViewState.currentViewSelector)
        }
    }
    
    // Moves the selected playlist item up one row in the playlist
    @IBAction func moveItemsToBottomAction(_ sender: Any) {
        
        if !checkIfPlaylistIsBeingModified() {
            messenger.publish(.playlist_moveTracksToBottom, payload: PlaylistViewState.currentViewSelector)
        }
    }
    
    // Presents the search modal dialog to allow the user to search for playlist tracks
    @IBAction func playlistSearchAction(_ sender: Any) {
        messenger.publish(.playlist_search)
    }
    
    // Presents the sort modal dialog to allow the user to sort playlist tracks
    @IBAction func playlistSortAction(_ sender: Any) {
        
        if !checkIfPlaylistIsBeingModified() {
            messenger.publish(.playlist_sort)
        }
    }
    
    // Plays the selected playlist item (track or group)
    @IBAction func playSelectedItemAction(_ sender: Any) {
        
        if WindowManager.instance.isChaptersListWindowKey {
            messenger.publish(.chaptersList_playSelectedChapter)
            
        } else {
            messenger.publish(.playlist_playSelectedItem, payload: PlaylistViewState.currentViewSelector)
        }
    }
    
    @IBAction func clearSelectionAction(_ sender: Any) {
        messenger.publish(.playlist_clearSelection, payload: PlaylistViewState.currentViewSelector)
    }
    
    @IBAction func invertSelectionAction(_ sender: Any) {
        messenger.publish(.playlist_invertSelection, payload: PlaylistViewState.currentViewSelector)
    }
    
    @IBAction func cropSelectionAction(_ sender: Any) {
        
        if !checkIfPlaylistIsBeingModified() {
            messenger.publish(.playlist_cropSelection, payload: PlaylistViewState.currentViewSelector)
        }
    }
    
    @IBAction func expandSelectedGroupsAction(_ sender: Any) {
        messenger.publish(.playlist_expandSelectedGroups, payload: PlaylistViewState.currentViewSelector)
    }
    
    @IBAction func collapseSelectedItemsAction(_ sender: Any) {
        messenger.publish(.playlist_collapseSelectedItems, payload: PlaylistViewState.currentViewSelector)
    }
    
    @IBAction func expandAllGroupsAction(_ sender: Any) {
        messenger.publish(.playlist_expandAllGroups, payload: PlaylistViewState.currentViewSelector)
    }
    
    @IBAction func collapseAllGroupsAction(_ sender: Any) {
        messenger.publish(.playlist_collapseAllGroups, payload: PlaylistViewState.currentViewSelector)
    }
    
    // Scrolls the current playlist view to the very top
    @IBAction func scrollToTopAction(_ sender: Any) {
        messenger.publish(.playlist_scrollToTop, payload: PlaylistViewState.currentViewSelector)
    }
    
    // Scrolls the current playlist view to the very bottom
    @IBAction func scrollToBottomAction(_ sender: Any) {
        messenger.publish(.playlist_scrollToBottom, payload: PlaylistViewState.currentViewSelector)
    }
    
    @IBAction func pageUpAction(_ sender: Any) {
        messenger.publish(.playlist_pageUp, payload: PlaylistViewState.currentViewSelector)
    }
    @IBAction func pageDownAction(_ sender: Any) {
        messenger.publish(.playlist_pageDown, payload: PlaylistViewState.currentViewSelector)
    }
    
    @IBAction func previousPlaylistViewAction(_ sender: Any) {
        messenger.publish(.playlist_previousView)
    }
    
    @IBAction func nextPlaylistViewAction(_ sender: Any) {
        messenger.publish(.playlist_nextView)
    }
    
    private func checkIfPlaylistIsBeingModified() -> Bool {
        
        let playlistBeingModified = playlist.isBeingModified
        
        if playlistBeingModified {
            alertDialog.showAlert(.error, "Playlist not modified", "The playlist cannot be modified while tracks are being added", "Please wait till the playlist is done adding tracks ...")
        }
        
        return playlistBeingModified
    }
}
