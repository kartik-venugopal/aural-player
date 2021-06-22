/*
    View controller that handles the assembly of the player view tree from its multiple pieces, and switches between high-level views depending on current player state (i.e. playing / stopped, etc).
 
    The player view tree consists of:
        
        - Playing track info (track info, art, etc)
            - Default view
            - Expanded Art view
 
        - Player controls (play/seek, next/previous track, repeat/shuffle, volume/balance)
 
        - Functions toolbar (detailed track info / favorite / bookmark, etc)
 */
import Cocoa

class PlayerViewController: NSViewController, NotificationSubscriber, Destroyable {

    @IBOutlet weak var playbackViewController: PlaybackViewController!
    @IBOutlet weak var playerSequencingViewController: PlayerSequencingViewController!
    @IBOutlet weak var playerAudioViewController: PlayerAudioViewController!
    @IBOutlet weak var playingTrackFunctionsViewController: PlayingTrackFunctionsViewController!
    
    @IBOutlet weak var infoView: PlayingTrackView!
    
    // Delegate that conveys all seek and playback info requests to the player
    private let player: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    private let fontSchemesManager: FontSchemesManager = ObjectGraph.fontSchemesManager
    private let colorSchemesManager: ColorSchemesManager = ObjectGraph.colorSchemesManager
    
    override var nibName: String? {"Player"}
    
    override func viewDidLoad() {
        
        initSubscriptions()
        
        infoView.applyFontScheme(fontSchemesManager.systemScheme)
        infoView.applyColorScheme(colorSchemesManager.systemScheme)
        
        infoView.showView()
        
        trackChanged(player.playingTrack)
    }

    // Subscribe to various notifications
    private func initSubscriptions() {
        
        Messenger.subscribe(self, .player_chapterChanged, self.chapterChanged(_:))
        Messenger.subscribe(self, .player_trackNotPlayed, self.trackNotPlayed)
        
        // Only respond if the playing track was updated
        Messenger.subscribeAsync(self, .player_trackInfoUpdated, self.playingTrackInfoUpdated(_:),
                                 filter: {msg in msg.updatedTrack == self.player.currentTrack &&
                                    msg.updatedFields.contains(.art) || msg.updatedFields.contains(.displayInfo)},
                                 queue: .main)
        
        Messenger.subscribeAsync(self, .player_trackTransitioned, self.trackTransitioned(_:), queue: .main)
        
        Messenger.subscribe(self, .player_changeView, infoView.switchView(_:))
        Messenger.subscribe(self, .player_showOrHideAlbumArt, infoView.showOrHideAlbumArt)
        Messenger.subscribe(self, .player_showOrHideArtist, infoView.showOrHideArtist)
        Messenger.subscribe(self, .player_showOrHideAlbum, infoView.showOrHideAlbum)
        Messenger.subscribe(self, .player_showOrHideCurrentChapter, infoView.showOrHideCurrentChapter)
        Messenger.subscribe(self, .player_showOrHideMainControls, infoView.showOrHideMainControls)
        Messenger.subscribe(self, .player_showOrHidePlayingTrackInfo, infoView.showOrHidePlayingTrackInfo)
        Messenger.subscribe(self, .player_showOrHidePlayingTrackFunctions, infoView.showOrHidePlayingTrackFunctions)
        
        Messenger.subscribe(self, .applyTheme, infoView.applyTheme)
        Messenger.subscribe(self, .applyFontScheme, infoView.applyFontScheme(_:))
        Messenger.subscribe(self, .applyColorScheme, infoView.applyColorScheme(_:))
        Messenger.subscribe(self, .changeBackgroundColor, infoView.changeBackgroundColor(_:))
        
        Messenger.subscribe(self, .player_changeTrackInfoPrimaryTextColor, infoView.changePrimaryTextColor(_:))
        Messenger.subscribe(self, .player_changeTrackInfoSecondaryTextColor, infoView.changeSecondaryTextColor(_:))
        Messenger.subscribe(self, .player_changeTrackInfoTertiaryTextColor, infoView.changeTertiaryTextColor(_:))
    }
    
    func destroy() {
        
        ([playbackViewController, playerAudioViewController, playerSequencingViewController, playingTrackFunctionsViewController] as? [Destroyable])?.forEach {$0.destroy()}
        
        Messenger.unsubscribeAll(for: self)
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
    }
}
