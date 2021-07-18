//
//  PlayerViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    View controller that handles the assembly of the player view tree from its multiple pieces, and switches between high-level views depending on current player state (i.e. playing / stopped, etc).
 
    The player view tree consists of:
        
        - Playing track info (track info, art, etc)
            - Default view
            - Expanded Art view
 
        - Player controls (play/seek, next/previous track, repeat/shuffle, volume/balance)
 
        - Functions toolbar (detailed track info / favorite / bookmark, etc)
 */
class PlayerViewController: NSViewController, Destroyable {

    @IBOutlet weak var playbackViewController: PlaybackViewController!
    @IBOutlet weak var playerSequencingViewController: PlayerSequencingViewController!
    @IBOutlet weak var playerAudioViewController: PlayerAudioViewController!
    @IBOutlet weak var playingTrackFunctionsViewController: PlayingTrackFunctionsViewController!
    
    @IBOutlet weak var infoView: PlayingTrackView!
    
    // Delegate that conveys all seek and playback info requests to the player
    private let player: PlaybackInfoDelegateProtocol = objectGraph.playbackInfoDelegate
    
    private let fontSchemesManager: FontSchemesManager = objectGraph.fontSchemesManager
    private let colorSchemesManager: ColorSchemesManager = objectGraph.colorSchemesManager
    
    private let playlistPreferences: PlaylistPreferences = objectGraph.preferences.playlistPreferences
    
    override var nibName: String? {"Player"}
    
    private lazy var messenger = Messenger(for: self)
    
    private lazy var windowLayoutsManager: WindowLayoutsManager = objectGraph.windowLayoutsManager
    
    override func viewDidLoad() {
        
        initSubscriptions()
        
        infoView.applyFontScheme(fontSchemesManager.systemScheme)
        infoView.applyColorScheme(colorSchemesManager.systemScheme)
        
        infoView.showView()
        
        trackChanged(player.playingTrack)
    }

    // Subscribe to various notifications
    private func initSubscriptions() {
        
        messenger.subscribe(to: .player_chapterChanged, handler: chapterChanged(_:))
        messenger.subscribe(to: .player_trackNotPlayed, handler: trackNotPlayed)
        
        // Only respond if the playing track was updated
        messenger.subscribeAsync(to: .player_trackInfoUpdated, handler: playingTrackInfoUpdated(_:),
                                 filter: {msg in msg.updatedTrack == self.player.playingTrack &&
                                    msg.updatedFields.contains(.art) || msg.updatedFields.contains(.displayInfo)})
        
        messenger.subscribeAsync(to: .player_trackTransitioned, handler: trackTransitioned(_:))
        
        messenger.subscribe(to: .player_changeView, handler: infoView.switchView(_:))
        messenger.subscribe(to: .player_showOrHideAlbumArt, handler: infoView.showOrHideAlbumArt)
        messenger.subscribe(to: .player_showOrHideArtist, handler: infoView.showOrHideArtist)
        messenger.subscribe(to: .player_showOrHideAlbum, handler: infoView.showOrHideAlbum)
        messenger.subscribe(to: .player_showOrHideCurrentChapter, handler: infoView.showOrHideCurrentChapter)
        messenger.subscribe(to: .player_showOrHideMainControls, handler: infoView.showOrHideMainControls)
        messenger.subscribe(to: .player_showOrHidePlayingTrackInfo, handler: infoView.showOrHidePlayingTrackInfo)
        messenger.subscribe(to: .player_showOrHidePlayingTrackFunctions, handler: infoView.showOrHidePlayingTrackFunctions)
        
        messenger.subscribe(to: .applyTheme, handler: infoView.applyTheme)
        messenger.subscribe(to: .applyFontScheme, handler: infoView.applyFontScheme(_:))
        messenger.subscribe(to: .applyColorScheme, handler: infoView.applyColorScheme(_:))
        messenger.subscribe(to: .changeBackgroundColor, handler: infoView.changeBackgroundColor(_:))
        
        messenger.subscribe(to: .player_changeTrackInfoPrimaryTextColor, handler: infoView.changePrimaryTextColor(_:))
        messenger.subscribe(to: .player_changeTrackInfoSecondaryTextColor, handler: infoView.changeSecondaryTextColor(_:))
        messenger.subscribe(to: .player_changeTrackInfoTertiaryTextColor, handler: infoView.changeTertiaryTextColor(_:))
    }
    
    func destroy() {
        
        [playbackViewController, playerAudioViewController, playerSequencingViewController,
          playingTrackFunctionsViewController].forEach {($0 as? Destroyable)?.destroy()}
        
        messenger.unsubscribeFromAll()
    }
    
    private func trackChanged(_ track: Track?) {
        
        if let theTrack = track {
            infoView.trackInfo = PlayingTrackInfo(theTrack, player.playingChapter?.chapter.title)
            
        } else {
            infoView.trackInfo = nil
        }
    }
    
    func trackNotPlayed() {
        self.trackChanged(nil as Track?)
    }
    
    // When track info for the playing track changes, display fields need to be updated
    func playingTrackInfoUpdated(_ notification: TrackInfoUpdatedNotification) {
        infoView.update()
    }
    
    func chapterChanged(_ notification: ChapterChangedNotification) {
        
        if let playingTrack = player.playingTrack {
            infoView.trackInfo = PlayingTrackInfo(playingTrack, notification.newChapter?.chapter.title)
        }
    }
    
    // MARK: Message handling

    func trackTransitioned(_ notification: TrackTransitionNotification) {
        
        trackChanged(notification.endTrack)
        
        // If the playlist window has not yet been loaded, we need to handle this notification on behalf of the playlist window.
        guard !windowLayoutsManager.playlistWindowLoaded else {return}
        
        // New track has no chapters, or there is no new track
        if player.chapterCount == 0 {
            messenger.publish(.windowManager_hideChaptersListWindow)
            
        } // Only show chapters list if preferred by user
        else if playlistPreferences.showChaptersList {
            messenger.publish(.windowManager_showChaptersListWindow)
        }
    }
}
