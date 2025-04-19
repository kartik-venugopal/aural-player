//
//  PlayingTrackFunctionsMenuDelegate.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    View controller for the functions toolbar that is displayed whenever a track is currently playing.
    Handles functions relevant to the playing track, such as favoriting, bookmarking, viewing detailed info, etc.
 
    Also handles such requests from app menus.
 */
class PlayingTrackFunctionsMenuDelegate: NSObject, NSMenuDelegate, Destroyable {
    
    // Button to add/remove the currently playing track to/from the Favorites list
    @IBOutlet weak var favoritesMenuItem: ToggleMenuItem!
    
    @IBOutlet weak var playerView: NSView!
    
    @IBOutlet weak var rememberLastPositionMenuItem: ToggleMenuItem!
    
    // Delegate that provides access to the Favorites track list.
    private lazy var favorites: FavoritesDelegateProtocol = favoritesDelegate
    
    // Popup view that displays a brief notification when the currently playing track is added/removed to/from the Favorites list
    private lazy var infoPopup: InfoPopupViewController = InfoPopupViewController.instance
    
    private lazy var bookmarkInputReceiver: BookmarkNameInputReceiver = BookmarkNameInputReceiver()
    private lazy var bookmarkNamePopover: StringInputPopoverViewController = StringInputPopoverViewController.create(bookmarkInputReceiver)
    
    private lazy var messenger = Messenger(for: self)
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        updateFavoriteButtonState()
        
        // Subscribe to various notifications
        
        messenger.subscribe(to: .Favorites.itemAdded, handler: trackAddedToFavorites(_:))
        messenger.subscribe(to: .Favorites.itemsRemoved, handler: tracksRemovedFromFavorites(_:))
        
        messenger.subscribe(to: .Favorites.addOrRemove, handler: addOrRemoveFavorite)
        messenger.subscribe(to: .Player.bookmarkPosition, handler: bookmarkPosition)
        messenger.subscribe(to: .Player.bookmarkLoop, handler: bookmarkLoop)
        
        messenger.subscribeAsync(to: .Player.trackTransitioned, handler: trackTransitioned(_:))
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        
        updateFavoriteButtonState()
        updateRememberPositionMenuItemState()
    }
    
    private func updateRememberPositionMenuItemState() {
        
        if let playingTrack = player.playingTrack {
            rememberLastPositionMenuItem.onIf(playbackProfiles.hasFor(playingTrack))
        }
    }
    
    private func updateFavoriteButtonState() {
        
        if let playingTrack = player.playingTrack {
            favoritesMenuItem.onIf(favorites.favoriteExists(track: playingTrack))
        }
    }
    
    func destroy() {
        
        TrackInfoWindowController.destroy()
        messenger.unsubscribeFromAll()
        bookmarkNamePopover.destroy()
    }
    
    // Shows a popover with detailed information for the currently playing track, if there is one
    @IBAction func moreInfoAction(_ sender: AnyObject) {
        messenger.publish(.Player.trackInfo)
    }
    
    // Shows (selects) the currently playing track, within the playlist, if there is one
    @IBAction func showPlayingTrackAction(_ sender: Any) {
        messenger.publish(.PlayQueue.showPlayingTrack)
    }
    
    // Adds/removes the currently playing track to/from the "Favorites" list
    @IBAction func favoriteAction(_ sender: Any) {
        addOrRemoveFavorite()
    }
    
    private func addOrRemoveFavorite() {
        
        guard let playingTrack = player.playingTrack else {return}

        // Toggle the button state
        if favorites.favoriteExists(track: playingTrack) {
            favorites.removeFavorite(track: playingTrack)
            
        } else {
            favorites.addFavorite(track: playingTrack)
        }
    }
    
    // Adds the currently playing track position to/from the "Bookmarks" list
    @IBAction func bookmarkAction(_ sender: Any) {
        
        if let playingTrack = player.playingTrack {
            doBookmark(playingTrack, player.seekPosition.timeElapsed)
        }
    }
    
    private func bookmarkPosition() {
        bookmarkAction(self)
    }
    
    // When a bookmark menu item is clicked, the item is played
    private func bookmarkLoop() {
        
        // Check if we have a complete loop
        if let playingTrack = player.playingTrack, let loop = player.playbackLoop, let loopEndTime = loop.endTime {
            doBookmark(playingTrack, loop.startTime, loopEndTime)
        }
    }
    
    private func doBookmark(_ playingTrack: Track, _ startTime: Double, _ endTime: Double? = nil) {
        
        let formattedStartTime: String = ValueFormatter.formatSecondsToHMS(startTime)
        let defaultBookmarkName: String
        
        if let theEndTime = endTime {
            
            // Loop
            let formattedEndTime: String = ValueFormatter.formatSecondsToHMS(theEndTime)
            defaultBookmarkName = "\(playingTrack.displayName) (\(formattedStartTime) ⇄ \(formattedEndTime))"
            
        } else {
            
            // Single position
            defaultBookmarkName = "\(playingTrack.displayName) (\(formattedStartTime))"
        }
        
        bookmarkInputReceiver.context = BookmarkInputContext(track: playingTrack, startPosition: startTime,
                                                             endPosition: endTime, defaultName: defaultBookmarkName)

        
        // TODO: Is this really needed ???
        appModeManager.mainWindow?.makeKeyAndOrderFront(self)
        
        // Show popover relative to player view
        bookmarkNamePopover.show(playerView, NSRectEdge.maxX)
    }
    
    @IBAction func rememberLastPositionAction(_ sender: ToggleMenuItem) {
        messenger.publish(!rememberLastPositionMenuItem.isOn ? .Player.savePlaybackProfile : .Player.deletePlaybackProfile)
    }
    
    // MARK: Notif handling
    
    func trackAddedToFavorites(_ favorite: Favorite) {
        
        if let favTrack = favorite as? FavoriteTrack {
            favoritesUpdated([favTrack.track.file], true)
        }
    }
    
    func tracksRemovedFromFavorites(_ removedFavorites: Set<Favorite>) {
        favoritesUpdated(Set(removedFavorites.compactMap {($0 as? FavoriteTrack)?.track.file}), false)
    }
    
    // Responds to a notification that a track has been added to / removed from the Favorites list, by updating the UI to reflect the new state
    private func favoritesUpdated(_ updatedFavoritesFiles: Set<URL>, _ added: Bool) {
        
        // Do this only if the track in the message is the playing track
        guard let playingTrack = player.playingTrack,
                updatedFavoritesFiles.contains(playingTrack.file) else {return}
        
        // TODO: Is this really required ???
        appModeManager.mainWindow?.makeKeyAndOrderFront(self)
        
        updateFavoriteButtonState()
        
        infoPopup.showMessage(added ? "Track added to Favorites !" : "Track removed from Favorites !",
                                  playerView, .maxX)
    }
    
    private func trackTransitioned(_ notification: TrackTransitionNotification) {
        
        if notification.endTrack != nil {
            updateRememberPositionMenuItemState()
        }
    }
}
