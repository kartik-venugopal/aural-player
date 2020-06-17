/*
    View controller for the Now Playing info box which displays information about the currently playing track
 */
import Cocoa

class PlayingTrackViewController: NSViewController, ActionMessageSubscriber, MessageSubscriber {
    
    @IBOutlet weak var infoView: PlayingTrackView!
    
    // Delegate that conveys all seek and playback info requests to the player
    private let player: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    override var nibName: String? {return "PlayingTrack"}
    
    override func viewDidLoad() {
        
        initSubscriptions()
        
        infoView.changeTextSize(PlayerViewState.textSize)
        infoView.applyColorScheme(ColorSchemes.systemScheme)
    }

    // Subscribe to various notifications
    private func initSubscriptions() {
        
        Messenger.subscribe(self, .chapterChanged, self.chapterChanged(_:))
        Messenger.subscribe(self, .trackNotPlayed, self.trackNotPlayed)
        
        // Only respond if the playing track was updated
        Messenger.subscribeAsync(self, .trackInfoUpdated, self.playingTrackInfoUpdated(_:),
                                 filter: {msg in msg.updatedTrack == self.player.currentTrack &&
                                    msg.updatedFields.contains(.art) || msg.updatedFields.contains(.displayInfo)},
                                 queue: .main)
        
        Messenger.subscribeAsync(self, .trackTransition, self.trackTransitioned(_:), queue: .main)
        
        Messenger.subscribe(self, .changePlayerTextSize, infoView.changeTextSize(_:))
        
        Messenger.subscribe(self, .player_changeView, infoView.switchView(_:))
        Messenger.subscribe(self, .player_showOrHideAlbumArt, infoView.showOrHideAlbumArt)
        Messenger.subscribe(self, .player_showOrHideArtist, infoView.showOrHideArtist)
        Messenger.subscribe(self, .player_showOrHideAlbum, infoView.showOrHideAlbum)
        Messenger.subscribe(self, .player_showOrHideCurrentChapter, infoView.showOrHideCurrentChapter)
        Messenger.subscribe(self, .player_showOrHideMainControls, infoView.showOrHideMainControls)
        Messenger.subscribe(self, .player_showOrHidePlayingTrackInfo, infoView.showOrHidePlayingTrackInfo)
        Messenger.subscribe(self, .player_showOrHidePlayingTrackFunctions, infoView.showOrHidePlayingTrackFunctions)
        
        Messenger.subscribe(self, .colorScheme_applyColorScheme, infoView.applyColorScheme(_:))
        
        SyncMessenger.subscribe(actionTypes: [.changeBackgroundColor, .changePlayerTrackInfoPrimaryTextColor, .changePlayerTrackInfoSecondaryTextColor, .changePlayerTrackInfoTertiaryTextColor], subscriber: self)
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

    func consumeMessage(_ message: ActionMessage) {
        
        if let colorComponentActionMsg = message as? ColorSchemeComponentActionMessage {
            
            infoView.applyColorSchemeComponent(colorComponentActionMsg)
            return
        }
    }
    
    func trackTransitioned(_ notification: TrackTransitionNotification) {
        trackChanged(notification.endTrack)
    }
}

// Encapsulates displayed information for the currently playing track.
struct PlayingTrackInfo {
    
    let track: Track
    let playingChapterTitle: String?
    
    init(_ track: Track, _ playingChapterTitle: String?) {
        
        self.track = track
        self.playingChapterTitle = playingChapterTitle
    }
    
    var art: NSImage? {
        return track.displayInfo.art?.image
    }
    
    var artist: String? {
        return track.displayInfo.artist
    }
    
    var album: String? {
        return track.groupingInfo.album
    }
    
    var displayName: String? {
        return track.displayInfo.title ?? track.conciseDisplayName
    }
}
