/*
    View controller for the Now Playing info box which displays information about the currently playing track
 */

import Cocoa

class TrackInfoViewController: NSViewController, MessageSubscriber, AsyncMessageSubscriber, ConstituentView {
    
    // Fields that display playing track info
    @IBOutlet weak var lblTrackArtist: NSTextField!
    @IBOutlet weak var lblTrackTitle: NSTextField!
    @IBOutlet weak var lblTrackName: NSTextField!
    
    @IBOutlet weak var artView: NSImageView!
    
    // Fields that display information about the current playback scope
    @IBOutlet weak var lblSequenceProgress: NSTextField!
    @IBOutlet weak var lblPlaybackScope: NSTextField!
    @IBOutlet weak var imgScope: NSImageView!
    
    // Delegate that conveys all seek and playback info requests to the player
    private let player: PlaybackInfoDelegateProtocol = ObjectGraph.getPlaybackInfoDelegate()
    
    override func viewDidLoad() {
        
        // Use persistent app state to determine the initial state of the view
        AppModeManager.registerConstituentView(.regular, self)
    }
    
    func activate() {
        
        initSubscriptions()
        
        let newTrack = player.getPlayingTrack()
        
        if (newTrack != nil) {
            
            showNowPlayingInfo(newTrack!.track)
            
        } else {
            
            // No track playing, clear the info fields
            clearNowPlayingInfo()
        }
    }
    
    func deactivate() {
        removeSubscriptions()
    }
    
    private func initSubscriptions() {
        
        // Subscribe to various notifications
        
        AsyncMessenger.subscribe([.tracksRemoved], subscriber: self, dispatchQueue: DispatchQueue.main)
        
        SyncMessenger.subscribe(messageTypes: [.trackChangedNotification, .sequenceChangedNotification, .playingTrackInfoUpdatedNotification], subscriber: self)
    }
    
    private func removeSubscriptions() {
        
        AsyncMessenger.unsubscribe([.tracksRemoved, .addedToFavorites, .removedFromFavorites], subscriber: self)
        
        SyncMessenger.unsubscribe(messageTypes: [.trackChangedNotification, .sequenceChangedNotification, .playingTrackInfoUpdatedNotification], subscriber: self)
    }
    
    private func showNowPlayingInfo(_ track: Track) {
        
        var artistAndTitleAvailable: Bool = false
        
        if (track.displayInfo.hasArtistAndTitle()) {
            
            artistAndTitleAvailable = true
            
            // Both title and artist
            lblTrackArtist.stringValue = track.displayInfo.artist!
            lblTrackTitle.stringValue = track.displayInfo.title!
            
        } else {
            
            lblTrackName.stringValue = track.conciseDisplayName
            
            // Re-position and resize the track name label, depending on whether it is displaying one or two lines of text (i.e. depending on the length of the track name)
            
            // Determine how many lines the track name will occupy, within the label
            let numLines = StringUtils.numberOfLines(track.conciseDisplayName, lblTrackName.font!, lblTrackName.frame.width)
            
            // The Y co-ordinate is a pre-determined constant
            var origin = lblTrackName.frame.origin
            origin.y = numLines == 1 ? Dimensions.trackNameLabelLocationY_oneLine : Dimensions.trackNameLabelLocationY_twoLines
            
            // The height is a pre-determined constant
            var lblFrameSize = lblTrackName.frame.size
            lblFrameSize.height = numLines == 1 ? Dimensions.trackNameLabelHeight_oneLine : Dimensions.trackNameLabelHeight_twoLines
            
            // Resize the label
            lblTrackName.setFrameSize(lblFrameSize)
            
            // Re-position the label
            lblTrackName.setFrameOrigin(origin)
        }
        
        lblTrackName.isHidden = artistAndTitleAvailable
        [lblTrackArtist, lblTrackTitle].forEach({$0?.isHidden = !artistAndTitleAvailable})
        
        if (track.displayInfo.art != nil) {
            artView.image = track.displayInfo.art!
        } else {
            
            // Default artwork
            let playing = player.getPlaybackState() == .playing
            artView.image = playing ? Images.imgPlayingArt : Images.imgPausedArt
        }
        
        showPlaybackScope()
    }
    
    /*
     Displays information about the current playback scope (i.e. the set of tracks that make up the current playback sequence - for ex. a specific artist group, or all tracks), and progress within that sequence - for ex. 5/67 (5th track playing out of a total of 67 tracks).
     */
    private func showPlaybackScope() {
        
        let sequence = player.getPlaybackSequenceInfo()
        let scope = sequence.scope
        
        // Description and image for playback scope
        switch scope.type {
            
        case .allTracks, .allArtists, .allAlbums, .allGenres:
            
            lblPlaybackScope.stringValue = StringUtils.splitCamelCaseWord(scope.type.rawValue, false)
            imgScope.image = Images.imgPlaylistOn
            
        case .artist, .album, .genre:
            
            lblPlaybackScope.stringValue = scope.scope!.name
            imgScope.image = Images.imgGroup_noPadding
        }
        
        // Sequence progress. For example, "5 / 10" (tracks)
        let trackIndex = sequence.trackIndex
        let totalTracks = sequence.totalTracks
        lblSequenceProgress.stringValue = String(format: "%d / %d", trackIndex, totalTracks)
        
        // Dynamically position the scope image relative to the scope description string
        
        // Determine the width of the scope string
        let scopeString: NSString = lblPlaybackScope.stringValue as NSString
        let stringSize: CGSize = scopeString.size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): lblPlaybackScope.font as AnyObject]))
        let lblWidth = lblPlaybackScope.frame.width
        let textWidth = min(stringSize.width, lblWidth)
        
        // Position the scope image a few pixels to the left of the scope string
        let margin = (lblWidth - textWidth) / 2
        let newImgX = lblPlaybackScope.frame.origin.x + margin - imgScope.frame.width - 4
        imgScope.frame.origin.x = max(lblTrackTitle.frame.minX, newImgX)
    }
    
    private func clearNowPlayingInfo() {
        
        [lblTrackArtist, lblTrackTitle, lblPlaybackScope, lblSequenceProgress].forEach({$0?.stringValue = ""})
        lblTrackName.stringValue = ""
        
        artView.image = Images.imgPausedArt
        
        imgScope.image = nil
    }
    private func tracksRemoved(_ message: TracksRemovedAsyncMessage) {
        
        // Check if the playing track was removed. If so, need to update display fields, because playback will have stopped.
        if (message.playingTrackRemoved) {
            trackChanged(nil)
        }
    }
    
    // The "errorState" arg indicates whether the player is in an error state (i.e. the new track cannot be played back). If so, update the UI accordingly.
    private func trackChanged(_ newTrack: IndexedTrack?) {
        
        if (newTrack != nil) {
            showNowPlayingInfo(newTrack!.track)
        } else {
            
            // No track playing, clear the info fields
            clearNowPlayingInfo()
        }
    }
    
    // When track info for the playing track changes, display fields need to be updated
    private func playingTrackInfoUpdated(_ notification: PlayingTrackInfoUpdatedNotification) {
        showNowPlayingInfo(player.getPlayingTrack()!.track)
    }
    
    private func sequenceChanged() {
        
        let sequence = player.getPlaybackSequenceInfo()
        lblSequenceProgress.stringValue = String(format: "%d / %d", sequence.trackIndex, sequence.totalTracks)
    }
    
    // MARK: Message handling
    
    func getID() -> String {
        return self.className
    }
    
    // Consume synchronous notification messages
    func consumeNotification(_ notification: NotificationMessage) {
        
        switch notification.messageType {
            
        case .trackChangedNotification:
            
            trackChanged((notification as! TrackChangedNotification).newTrack)
            
        case .playingTrackInfoUpdatedNotification:
            
            playingTrackInfoUpdated(notification as! PlayingTrackInfoUpdatedNotification)
            
        case .sequenceChangedNotification:
            
            sequenceChanged()
            
        default: return
            
        }
    }
    
    // Consume asynchronous messages
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        switch message.messageType {
            
        case .tracksRemoved:
            
            tracksRemoved(message as! TracksRemovedAsyncMessage)
            
        default: return
            
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
    return input.rawValue
}

class DefaultPlayerTrackInfoViewController: TrackInfoViewController {}

class ExpandedArtPlayerTrackInfoViewController: TrackInfoViewController {}
