//
//  PlayingTrackFunctionsViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
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
class PlayingTrackFunctionsViewController: NSViewController, NotificationSubscriber, Destroyable {
    
    // Button to display more details about the playing track
    @IBOutlet weak var btnMoreInfo: TintedImageButton!
    
    // Button to add/remove the currently playing track to/from the Favorites list
    @IBOutlet weak var btnFavorite: OnOffImageButton!
    
    // Button to bookmark current track and position
    @IBOutlet weak var btnBookmark: TintedImageButton!
    
    @IBOutlet weak var sliderView: SeekSliderView!
    @IBOutlet weak var seekPositionMarkerView: NSView!
    
    @IBOutlet weak var btnShowPlayingTrackInPlaylist: TintedImageButton!
    
    // Delegate that provides info about the playing track
    private lazy var player: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    // Delegate that provides access to History information
    private lazy var favorites: FavoritesDelegateProtocol = ObjectGraph.favoritesDelegate
    
    private lazy var trackReader: TrackReader = ObjectGraph.trackReader
    
    // Popover view that displays detailed info for the currently playing track
    private lazy var detailedInfoPopover: DetailedTrackInfoViewController = {
        
        detailedInfoPopoverLoaded = true
        return DetailedTrackInfoViewController.instance
    }()
    
    private var detailedInfoPopoverLoaded: Bool = false
    
    // Popup view that displays a brief notification when the currently playing track is added/removed to/from the Favorites list
    private lazy var infoPopup: InfoPopupProtocol = InfoPopupViewController.instance
    
    private lazy var bookmarkNamePopover: StringInputPopoverViewController = StringInputPopoverViewController.create(BookmarkNameInputReceiver())
    
    private let colorSchemesManager: ColorSchemesManager = ObjectGraph.colorSchemesManager
    
    private var allButtons: [Tintable] = []
    
    override func viewDidLoad() {
        
        allButtons = [btnMoreInfo, btnShowPlayingTrackInPlaylist, btnFavorite, btnBookmark]
        redrawButtons()
        
        // Subscribe to various notifications
        
        // TODO: Add a subscribe() method overload to Messenger that takes multiple notif names for a single msgHandler ???
        Messenger.subscribe(self, .favoritesList_trackAdded, self.trackAddedToFavorites(_:))
        Messenger.subscribe(self, .favoritesList_tracksRemoved, self.tracksRemovedFromFavorites(_:))
        
        Messenger.subscribeAsync(self, .player_trackTransitioned, self.trackTransitioned(_:),
                                 filter: {msg in msg.trackChanged},
                                 queue: .main)
        Messenger.subscribeAsync(self, .player_trackNotPlayed, self.noTrackPlaying, queue: .main)
        
        Messenger.subscribe(self, .player_moreInfo, self.moreInfo)
        Messenger.subscribe(self, .favoritesList_addOrRemove, self.addOrRemoveFavorite)
        Messenger.subscribe(self, .player_bookmarkPosition, self.bookmarkPosition)
        Messenger.subscribe(self, .player_bookmarkLoop, self.bookmarkLoop)
        
        Messenger.subscribe(self, .applyTheme, self.applyTheme)
        Messenger.subscribe(self, .applyColorScheme, self.applyColorScheme(_:))
        Messenger.subscribe(self, .changeFunctionButtonColor, self.changeFunctionButtonColor(_:))
        Messenger.subscribe(self, .changeToggleButtonOffStateColor, self.changeToggleButtonOffStateColor(_:))
    }
    
    func destroy() {
        
        DetailedTrackInfoViewController.destroy()
        Messenger.unsubscribeAll(for: self)
    }
    
    private func moreInfo() {
        moreInfoAction(self)
    }
    
    // Shows a popover with detailed information for the currently playing track, if there is one
    @IBAction func moreInfoAction(_ sender: AnyObject) {
        
        // If there is a track currently playing, load detailed track info and toggle the popover view
        if let playingTrack = player.playingTrack {
            
            if detailedInfoPopover.isShown {
                
                detailedInfoPopover.close()
                
            } else {
                
                detailedInfoPopover.attachedToPlayer = true
                
                // TODO: This should be done through a delegate (TrackDelegate ???)
                trackReader.loadAuxiliaryMetadata(for: playingTrack)
                
                WindowManager.instance.mainWindow.makeKeyAndOrderFront(self)
                
                let autoHideIsOn: Bool = PlayerViewState.viewType == .expandedArt || !PlayerViewState.showControls
                
                if btnMoreInfo.isVisible && !autoHideIsOn {
                    
                    detailedInfoPopover.show(playingTrack, btnMoreInfo, NSRectEdge.maxX)
                    
                } else if let windowRootView = self.view.window?.contentView {
                    
                    detailedInfoPopover.show(playingTrack, windowRootView, NSRectEdge.maxX)
                }
            }
        }
    }
    
    // Shows (selects) the currently playing track, within the playlist, if there is one
    @IBAction func showPlayingTrackAction(_ sender: Any) {
        Messenger.publish(.playlist_showPlayingTrack, payload: PlaylistViewSelector.forView(PlaylistViewState.currentView))
    }
    
    // Adds/removes the currently playing track to/from the "Favorites" list
    @IBAction func favoriteAction(_ sender: Any) {
        
        if let playingTrack = player.playingTrack {
            
            // Toggle the button state
            btnFavorite.toggle()
            
            btnFavorite.isOn ? _ = favorites.addFavorite(playingTrack) : favorites.deleteFavoriteWithFile(playingTrack.file)
        }
    }
    
    private func addOrRemoveFavorite() {
        favoriteAction(self)
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
        
        BookmarkContext.bookmarkedTrack = playingTrack
        BookmarkContext.bookmarkedTrackStartPosition = startTime
        BookmarkContext.bookmarkedTrackEndPosition = endTime
        
        if let theEndTime = endTime {
            
            // Loop
            BookmarkContext.defaultBookmarkName = String(format: "%@ (%@ ⇄ %@)", playingTrack.displayName, ValueFormatter.formatSecondsToHMS(startTime), ValueFormatter.formatSecondsToHMS(theEndTime))
            
        } else {
            
            // Single position
            BookmarkContext.defaultBookmarkName = String(format: "%@ (%@)", playingTrack.displayName, ValueFormatter.formatSecondsToHMS(startTime))
        }
        
        // Show popover
        
        let autoHideIsOn: Bool = PlayerViewState.viewType == .expandedArt || !PlayerViewState.showControls
        
        WindowManager.instance.mainWindow.makeKeyAndOrderFront(self)
        
        // If controls are being auto-hidden, don't display popover relative to any view within the window. Show it relative to the window itself.
        if autoHideIsOn {

            // Show popover relative to window
            if let windowRootView = self.view.window?.contentView {
                bookmarkNamePopover.show(windowRootView, NSRectEdge.maxX)
            }
            
        } else {
            
            sliderView.positionSeekPositionMarkerView()
            
            // Show popover relative to seek slider
            if seekPositionMarkerView.isVisible {
                bookmarkNamePopover.show(seekPositionMarkerView, NSRectEdge.maxY)

            } // Show popover relative to bookmark function button
            else if btnBookmark.isVisible {
                bookmarkNamePopover.show(btnBookmark, NSRectEdge.maxX)
                
            } // Show popover relative to window
            else if let windowRootView = self.view.window?.contentView {
                bookmarkNamePopover.show(windowRootView, NSRectEdge.maxX)
            }
        }
    }
    
    func trackAddedToFavorites(_ trackFile: URL) {
        favoritesUpdated([trackFile], true)
    }
    
    func tracksRemovedFromFavorites(_ removedFavoritesFiles: Set<URL>) {
        favoritesUpdated(removedFavoritesFiles, false)
    }
    
    // Responds to a notification that a track has been added to / removed from the Favorites list, by updating the UI to reflect the new state
    private func favoritesUpdated(_ updatedFavoritesFiles: Set<URL>, _ added: Bool) {
        
        // Do this only if the track in the message is the playing track
        if let playingTrack = player.playingTrack, updatedFavoritesFiles.contains(playingTrack.file) {
            
            // TODO: Is this really required ???
            WindowManager.instance.mainWindow.makeKeyAndOrderFront(self)
            
            btnFavorite.onIf(added)
            
            let autoHideIsOn: Bool = PlayerViewState.viewType == .expandedArt || !PlayerViewState.showControls
            
            if btnFavorite.isVisible && !autoHideIsOn {
                
                infoPopup.showMessage(added ? "Track added to Favorites !" : "Track removed from Favorites !", btnFavorite, NSRectEdge.maxX)
                
            } else if let windowRootView = self.view.window?.contentView {
                
                infoPopup.showMessage(added ? "Track added to Favorites !" : "Track removed from Favorites !", windowRootView, NSRectEdge.maxX)
            }
        }
    }
    
    private func newTrackStarted(_ track: Track) {
        btnFavorite.onIf(favorites.favoriteWithFileExists(track.file))
    }
    
    private func noTrackPlaying() {
        
        if detailedInfoPopoverLoaded {
            detailedInfoPopover.close()
        }
    }
    
    private func trackChanged(_ newTrack: Track?) {
        
        if let theNewTrack = newTrack {
            
            newTrackStarted(theNewTrack)
            
            if detailedInfoPopoverLoaded && detailedInfoPopover.isShown && detailedInfoPopover.attachedToPlayer {
                
                trackReader.loadAuxiliaryMetadata(for: theNewTrack)
                detailedInfoPopover.refresh(theNewTrack)
            }
            
        } else {
            
            // No track playing, clear the info fields
            noTrackPlaying()
        }
    }
    
    private func applyTheme() {
        applyColorScheme(colorSchemesManager.systemScheme)
    }
    
    private func applyColorScheme(_ scheme: ColorScheme) {
        redrawButtons()
    }
    
    private func changeFunctionButtonColor(_ color: NSColor) {
        redrawButtons()
    }
    
    private func redrawButtons() {
        allButtons.forEach {$0.reTint()}
    }
    
    private func changeToggleButtonOffStateColor(_ color: NSColor) {
        btnFavorite.reTint()
    }
    
    // MARK: Message handling
    
    func trackTransitioned(_ notification: TrackTransitionNotification) {
        trackChanged(notification.endTrack)
    }
}
