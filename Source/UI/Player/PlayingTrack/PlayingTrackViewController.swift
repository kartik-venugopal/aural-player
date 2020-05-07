/*
    View controller for the Now Playing info box which displays information about the currently playing track
 */

import Cocoa

class PlayingTrackViewController: NSViewController, ActionMessageSubscriber, MessageSubscriber, AsyncMessageSubscriber {
    
    @IBOutlet weak var infoView: PlayingTrackView!
    
    // Delegate that conveys all seek and playback info requests to the player
    private let player: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    override var nibName: String? {return "PlayingTrack"}
    
    override func viewDidLoad() {
        
        initSubscriptions()
        
        infoView.changeTextSize(PlayerViewState.textSize)
        infoView.applyColorScheme(ColorSchemes.systemScheme)
    }
    
    private func initSubscriptions() {
        
        // Subscribe to various notifications
        
        AsyncMessenger.subscribe([.trackNotPlayed], subscriber: self, dispatchQueue: DispatchQueue.main)
        
        SyncMessenger.subscribe(messageTypes: [.trackChangedNotification, .chapterChangedNotification, .playingTrackInfoUpdatedNotification], subscriber: self)
        
        SyncMessenger.subscribe(actionTypes: [.changePlayerView, .showOrHideAlbumArt, .showOrHideArtist, .showOrHideAlbum, .showOrHideCurrentChapter, .showOrHideMainControls, .showOrHidePlayingTrackInfo, .showOrHideSequenceInfo, .showOrHidePlayingTrackFunctions, .changePlayerTextSize, .applyColorScheme, .changeBackgroundColor, .changePlayerTrackInfoPrimaryTextColor, .changePlayerTrackInfoSecondaryTextColor, .changePlayerTrackInfoTertiaryTextColor], subscriber: self)
    }
    
    private func showView() {
        infoView.show()
    }
    
    private func trackChanged(_ track: Track?) {
        infoView.trackInfo = PlayingTrackInfo(track, player.playingChapter?.chapter.title)
    }
    
    private func trackNotPlayed(_ message: TrackNotPlayedAsyncMessage) {
        self.trackChanged(nil as Track?)
    }
    
    // When track info for the playing track changes, display fields need to be updated
    private func playingTrackInfoUpdated(_ notification: PlayingTrackInfoUpdatedNotification) {
        
        // TODO: Do a switch here ... on state
        infoView.update()
    }
    
    private func chapterChanged(_ newChapter: IndexedChapter?) {
        
        if PlayerViewState.showCurrentChapter {
            infoView.trackInfo = PlayingTrackInfo(player.playingTrack?.track, newChapter?.chapter.title)
        }
    }
    
    // MARK: Message handling
    
    var subscriberId: String {
        return self.className
    }
    
    func consumeMessage(_ message: ActionMessage) {
        
        if let pvActionMsg = message as? PlayerViewActionMessage {
            
            infoView.performAction(pvActionMsg)
            return
            
        } else if let colorComponentActionMsg = message as? ColorSchemeComponentActionMessage {
            
            infoView.applyColorSchemeComponent(colorComponentActionMsg)
            return
            
        } else if let colorSchemeActionMsg = message as? ColorSchemeActionMessage {
            
            infoView.applyColorScheme(colorSchemeActionMsg.scheme)
            
        } else if let textSizeMessage = message as? TextSizeActionMessage, textSizeMessage.actionType == .changePlayerTextSize {
            
            infoView.changeTextSize(textSizeMessage.textSize)
        }
    }
    
    // Consume synchronous notification messages
    func consumeNotification(_ notification: NotificationMessage) {
        
        if let trackChangedMsg = notification as? TrackChangedNotification {
            
            trackChanged(trackChangedMsg.newTrack?.track)
            return
            
        } else if let trackInfoUpdatedMsg = notification as? PlayingTrackInfoUpdatedNotification {
         
            playingTrackInfoUpdated(trackInfoUpdatedMsg)
            return
            
        } else if let chapterChangedMsg = notification as? ChapterChangedNotification {
            
            chapterChanged(chapterChangedMsg.newChapter)
            return
        }
    }
    
    // Consume asynchronous messages
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        if let trackNotPlayedMsg = message as? TrackNotPlayedAsyncMessage {
            
            trackNotPlayed(trackNotPlayedMsg)
            return
        }
    }
}

// Encapsulates displayed information for the currently playing track.
struct PlayingTrackInfo {
    
    let track: Track?
    let playingChapterTitle: String?
    
    init(_ track: Track?, _ playingChapterTitle: String?) {
        
        self.track = track
        self.playingChapterTitle = playingChapterTitle
    }
    
    var art: NSImage? {
        return track?.displayInfo.art?.image
    }
    
    var artist: String? {
        return track?.displayInfo.artist
    }
    
    var album: String? {
        return track?.groupingInfo.album
    }
    
    var displayName: String? {
        return track?.displayInfo.title ?? track?.conciseDisplayName
    }
}
