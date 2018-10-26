import Cocoa

@IBDesignable
class PlayerView: NSView {
    
    @IBOutlet weak var infoBox: NSBox!
    @IBOutlet weak var controlsBox: NSBox!
    @IBOutlet weak var functionsBox: NSBox!
    
    @IBOutlet weak var lblTrackArtist: NSTextField!
    @IBOutlet weak var lblTrackTitle: NSTextField!
    @IBOutlet weak var lblTrackName: NSTextField!
    
    @IBOutlet weak var artView: NSImageView!
    
    // Fields that display information about the current playback scope
    @IBOutlet weak var lblSequenceProgress: NSTextField!
    @IBOutlet weak var lblPlaybackScope: NSTextField!
    @IBOutlet weak var imgScope: NSImageView!
    
    // Gap info fields
    
    @IBOutlet weak var gapBox: NSBox!
    @IBOutlet weak var lblGapTrackName: NSTextField!
    @IBOutlet weak var lblGapTimeRemaining: NSTextField!
    
    private var gapTimer: RepeatingTaskExecutor?
    
    fileprivate let player: PlaybackInfoDelegateProtocol = ObjectGraph.getPlaybackInfoDelegate()
    
    fileprivate var infoBoxDefaultPosition: NSPoint { return NSPoint(x: 0, y: 46) }
    
    fileprivate var autoHideFields_showing: Bool = false
    
    func showView(_ playbackState: PlaybackState) {
        
        self.addSubview(controlsBox, positioned: .above, relativeTo: nil)
        self.addSubview(functionsBox)
        
        controlsBox.setFrameOrigin(NSPoint.zero)
        
        infoBox.setFrameOrigin(infoBoxDefaultPosition)
        functionsBox.hideIf(playbackState == .noTrack)
        centerFunctionsBox()
        
        if playbackState == .waiting {
            showGapFields()
        } else {
            gapBox.hide()
        }
        
    }
    
    fileprivate func centerFunctionsBox() {
        
        // Vertically center functions box w.r.t. info box
        let funcY = infoBox.frame.minY + (infoBox.frame.height / 2) - (functionsBox.frame.height / 2)
        functionsBox.setFrameOrigin(NSPoint(x: self.frame.width - 5 - functionsBox.frame.width, y: funcY))
    }
    
    func hideView() {
        
        controlsBox.removeFromSuperview()
        functionsBox.removeFromSuperview()
    }
    
    func showOrHidePlayingTrackInfo() {
        
        PlayerViewState.showPlayingTrackInfo = !PlayerViewState.showPlayingTrackInfo
        
        if PlayerViewState.showPlayingTrackInfo {
            
            infoBox.show()
            
        } else {
            
            infoBox.hide()
            
            PlayerViewState.showAlbumArt = true
            artView.show()
        }
    }
    
    func showOrHideAlbumArt() {
        
        PlayerViewState.showAlbumArt = !PlayerViewState.showAlbumArt
        
        if PlayerViewState.showAlbumArt {
            
            artView.show()
            
        } else {
            
            artView.hide()
            
            PlayerViewState.showPlayingTrackInfo = true
            infoBox.show()
        }
    }
    
    func showOrHidePlayingTrackFunctions() {
        
        PlayerViewState.showPlayingTrackFunctions = !PlayerViewState.showPlayingTrackFunctions
        functionsBox.showIf(PlayerViewState.showPlayingTrackFunctions)
    }
    
    func showOrHideMainControls() {
        
        PlayerViewState.showControls = !PlayerViewState.showControls
        controlsBox.showIf(PlayerViewState.showControls)
    }
    
    func mouseEntered() {
        autoHideFields_showing = true
    }
    
    func mouseExited() {
        autoHideFields_showing = false
    }
    
    func needsMouseTracking() -> Bool {
        return !PlayerViewState.showControls || !PlayerViewState.showPlayingTrackInfo
    }
    
    fileprivate func bringViewToFront(_ aView: NSView) {
        
        let superView = aView.superview
        aView.removeFromSuperview()
        superView?.addSubview(aView, positioned: .above, relativeTo: nil)
    }
    
    // MARK: Track info functions
    
    func showNowPlayingInfo(_ track: Track, _ playbackState: PlaybackState, _ sequence: (scope: SequenceScope, trackIndex: Int, totalTracks: Int)) {
        
        showPlayingTrackFields()
        
        var artistAndTitleAvailable: Bool = false
        
        if (track.displayInfo.hasArtistAndTitle()) {
            
            artistAndTitleAvailable = true
            
            // Both title and artist
            lblTrackArtist.stringValue = track.displayInfo.artist!
            lblTrackTitle.stringValue = track.displayInfo.title!
            
        } else {
            
            lblTrackName.stringValue = track.conciseDisplayName
            positionTrackNameLabel()
        }
        
        lblTrackName.hideIf(artistAndTitleAvailable)
        [lblTrackArtist, lblTrackTitle].forEach({$0?.showIf(artistAndTitleAvailable)})
        
        if (track.displayInfo.art != nil) {
            artView.image = track.displayInfo.art!
        } else {
            
            // Default artwork
            let playing = playbackState == .playing
            artView.image = playing ? Images.imgPlayingArt : Images.imgPausedArt
        }
        
        showPlaybackScope(sequence)
    }
    
    fileprivate func positionTrackNameLabel() {
        
        // Re-position and resize the track name label, depending on whether it is displaying one or two lines of text (i.e. depending on the length of the track name)
        
        // Determine how many lines the track name will occupy, within the label
        let numLines = StringUtils.numberOfLines(lblTrackName.stringValue, lblTrackName.font!, lblTrackName.frame.width)
        
        // The height is a pre-determined constant
        var lblFrameSize = lblTrackName.frame.size
        
        // TODO: Remove the constants, use artist/title label heights instead
        lblFrameSize.height = numLines == 1 ? lblTrackTitle.frame.height : lblTrackTitle.frame.height * 1.5
        
        // The Y co-ordinate is a pre-determined constant
        var origin = lblTrackName.frame.origin
        if numLines == 1 {
            
            // Center it wrt artist/title labels
            origin.y = lblTrackArtist.frame.minY + ((lblTrackArtist.frame.height + lblTrackTitle.frame.height) / 2) - (lblTrackName.frame.height / 2)
            
        } else {
            
            origin.y = lblTrackArtist.frame.minY
        }
        
        // Resize the label
        lblTrackName.setFrameSize(lblFrameSize)
        
        // Re-position the label
        lblTrackName.setFrameOrigin(origin)
    }
    
    /*
     Displays information about the current playback scope (i.e. the set of tracks that make up the current playback sequence - for ex. a specific artist group, or all tracks), and progress within that sequence - for ex. 5/67 (5th track playing out of a total of 67 tracks).
     */
    func showPlaybackScope(_ sequence: (scope: SequenceScope, trackIndex: Int, totalTracks: Int)) {
        
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
        
        positionScopeImage()
    }
    
    fileprivate func positionScopeImage() {
        
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
    
    func clearNowPlayingInfo() {
        
        [lblTrackArtist, lblTrackTitle, lblPlaybackScope, lblSequenceProgress].forEach({$0?.stringValue = ""})
        lblTrackName.stringValue = ""
        
        artView.image = Images.imgPausedArt
        
        imgScope.image = nil
    }
    
    func sequenceChanged(_ sequence: (scope: SequenceScope, trackIndex: Int, totalTracks: Int)) {
        lblSequenceProgress.stringValue = String(format: "%d / %d", sequence.trackIndex, sequence.totalTracks)
    }
    
    private func updateGapCountdown(_ endTime: Date) {
        
        let seconds = max(DateUtils.timeUntil(endTime), 0)
        lblGapTimeRemaining.stringValue = StringUtils.formatSecondsToHMS(seconds)
        
        if seconds == 0 {
            gapTimer?.stop()
            gapTimer = nil
        }
    }
    
    func gapStarted(_ msg: PlaybackGapStartedAsyncMessage) {
        
        showGapFields()
     
        let track = msg.nextTrack.track
        
        lblGapTrackName.stringValue = String(format: "Up next:   %@", track.conciseDisplayName)
        updateGapCountdown(msg.gapEndTime)
        
        if (track.displayInfo.art != nil) {
            
            artView.image = track.displayInfo.art!
            
        } else {
            
            // Default artwork
            artView.image = Images.imgPausedArt
        }
        
        gapTimer = RepeatingTaskExecutor(intervalMillis: 500, task: {
            
            self.updateGapCountdown(msg.gapEndTime)
            
        }, queue: DispatchQueue.main)
        
        gapTimer?.startOrResume()
    }
    
    private func showGapFields() {
        
        gapBox.setFrameOrigin(infoBox.frame.origin)
        gapBox.show()
        [functionsBox, infoBox].forEach({$0?.hide()})
    }
    
    private func showPlayingTrackFields() {
        
        if gapBox.isShown {
            gapBox.hide()
        }
            
        // TODO: Also show info box if auto-hide-showing
        infoBox.showIf(PlayerViewState.showPlayingTrackInfo || autoHideFields_showing)
        functionsBox.showIf(PlayerViewState.showPlayingTrackFunctions)
    }
    
    func handOff(_ otherView: PlayerView) {
        
        otherView.lblTrackName.stringValue = lblTrackName.stringValue
        otherView.lblTrackTitle.stringValue = lblTrackTitle.stringValue
        otherView.lblTrackArtist.stringValue = lblTrackArtist.stringValue
        otherView.artView.image = artView.image
        otherView.imgScope.image = imgScope.image
        otherView.lblPlaybackScope.stringValue = lblPlaybackScope.stringValue
        otherView.lblSequenceProgress.stringValue = lblSequenceProgress.stringValue
        
        otherView.lblTrackName.showIf(lblTrackName.isShown)
        otherView.lblTrackTitle.showIf(lblTrackTitle.isShown)
        otherView.lblTrackArtist.showIf(lblTrackArtist.isShown)
        
        otherView.positionTrackNameLabel()
        otherView.positionScopeImage()
    }
}

@IBDesignable
class DefaultPlayerView: PlayerView {
    
    private let artViewDefaultPosition: NSPoint = NSPoint(x: 10, y: 80)
    
    private let artViewYCentered: CGFloat = 50
    
    override var infoBoxDefaultPosition: NSPoint { return NSPoint(x: 90, y: 70) }
    private let infoBoxCenteredPosition: NSPoint = NSPoint(x: 90, y: 40)
    
    override func showView(_ playbackState: PlaybackState) {
        
        super.showView(playbackState)
        
        // Position the art view
        artView.setFrameOrigin(artViewDefaultPosition)
        
        PlayerViewState.showControls = true
        PlayerViewState.showPlayingTrackFunctions = true
        PlayerViewState.showAlbumArt = true
        PlayerViewState.showPlayingTrackInfo = true
        
        controlsBox.isTransparent = false

        artView.show()
        infoBox.show()
        controlsBox.show()
    }
    
    override func showOrHideMainControls() {
        
        super.showOrHideMainControls()
        
        // Re-position the info box, art view, and functions box
        infoBox.setFrameOrigin(PlayerViewState.showControls ? infoBoxDefaultPosition : infoBoxCenteredPosition)
        gapBox.setFrameOrigin(infoBox.frame.origin)
        
        artView.frame.origin.y = PlayerViewState.showControls ? artViewDefaultPosition.y : artViewYCentered
        centerFunctionsBox()
    }
    
    override func showOrHidePlayingTrackInfo() {
        // Do nothing (this function is not allowed on the default player view)
    }
    
    override func mouseEntered() {
        
        super.mouseEntered()
        
        if !PlayerViewState.showPlayingTrackInfo {
            autoHideInfo_show()
        }
        
        if !PlayerViewState.showControls {
            autoHideControls_show()
        }
    }
    
    override func mouseExited() {
        
        super.mouseExited()
        
        if !PlayerViewState.showPlayingTrackInfo {
            autoHideInfo_hide()
        }
        
        if !PlayerViewState.showControls {
            autoHideControls_hide()
        }
    }
    
    private func autoHideInfo_show() {
        
        infoBox.isTransparent = false
        infoBox.show()
    }
    
    private func autoHideInfo_hide() {
        
        infoBox.isTransparent = true
        infoBox.hide()
    }
    
    private func autoHideControls_show() {
        
        // Show controls
        controlsBox.show()
        
        infoBox.setFrameOrigin(infoBoxDefaultPosition)
        artView.frame.origin.y = artViewDefaultPosition.y
        centerFunctionsBox()
    }
    
    private func autoHideControls_hide() {
        
        // Hide controls
        controlsBox.hide()
        
        infoBox.setFrameOrigin(infoBoxCenteredPosition)
        artView.frame.origin.y = artViewYCentered
        centerFunctionsBox()
    }
}

@IBDesignable
class ExpandedArtPlayerView: PlayerView {
    
    private let infoBoxTopPosition: NSPoint = NSPoint(x: 0, y: 75)
    
    @IBOutlet weak var overlayBox: NSBox!
    
    override func showView(_ playbackState: PlaybackState) {
        
        super.showView(playbackState)
        
        // Show/hide individual components
        PlayerViewState.showControls = false
        PlayerViewState.showPlayingTrackFunctions = true
        PlayerViewState.showAlbumArt = true
        PlayerViewState.showPlayingTrackInfo = true
        
        controlsBox.isTransparent = true
        
        artView.show()
        controlsBox.hide()
        overlayBox.hide()
        
        infoBox.isTransparent = false
    }
    
    override func showOrHideMainControls() {
        // Do nothing (this function is not allowed on the expanded art player view)
    }
    
    override func showOrHideAlbumArt() {
        // Do nothing (this function is not allowed on the expanded art player view)
    }
    
    override func mouseEntered() {
        
        super.mouseEntered()
        
        autoHideControls_show()
        
        if !PlayerViewState.showPlayingTrackInfo {
            autoHideInfo_show()
        }
    }
    
    override func mouseExited() {
        
        super.mouseExited()
        
        if !PlayerViewState.showPlayingTrackInfo {
            autoHideInfo_hide()
        }
        
        autoHideControls_hide()
    }
    
    private func autoHideInfo_show() {
        
        infoBox.isTransparent = true
        gapBox.isTransparent = true
        
        let plState = player.getPlaybackState()
        if plState == .playing || plState == .paused {
            infoBox.show()
        }
    }
    
    private func autoHideInfo_hide() {
        
        infoBox.isTransparent = false
        gapBox.isTransparent = false
        
        if !PlayerViewState.showPlayingTrackInfo {
            infoBox.hide()
        }
    }
    
    private func autoHideControls_show() {
        
        // Show controls
        controlsBox.show()
        overlayBox.show()
        
        [infoBox, controlsBox, gapBox].forEach({$0?.isTransparent = true})
        
        [infoBox, controlsBox, functionsBox, gapBox].forEach({self.bringViewToFront($0)})
        
        // Re-position the info box, art view, and functions box
        let plState = player.getPlaybackState()
        if plState == .playing || plState == .paused {
            infoBox.show()
        }
        infoBox.setFrameOrigin(infoBoxTopPosition)
        gapBox.setFrameOrigin(infoBox.frame.origin)
        centerFunctionsBox()
    }
    
    private func autoHideControls_hide() {
        
        // Hide controls
        overlayBox.hide()
        controlsBox.hide()
        
        infoBox.isTransparent = false
        gapBox.isTransparent = false
        
        infoBox.setFrameOrigin(infoBoxDefaultPosition)
        gapBox.setFrameOrigin(infoBox.frame.origin)
        centerFunctionsBox()
        
        // Show info box as overlay temporarily
        if !PlayerViewState.showPlayingTrackInfo {
            infoBox.hide()
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
