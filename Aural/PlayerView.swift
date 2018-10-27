import Cocoa

@IBDesignable
class PlayerView: NSView {
    
    @IBOutlet weak var infoBox: NSBox!
    @IBOutlet weak var controlsBox: NSBox!
    @IBOutlet weak var functionsBox: NSBox!
    @IBOutlet weak var gapBox: NSBox!
    @IBOutlet weak var artView: NSImageView!
    
    fileprivate let player: PlaybackInfoDelegateProtocol = ObjectGraph.getPlaybackInfoDelegate()
    
    fileprivate var infoBoxDefaultPosition: NSPoint { return NSPoint(x: 0, y: 46) }
    
    fileprivate var autoHideFields_showing: Bool = false
    
    func showView(_ playbackState: PlaybackState) {
        
        self.addSubview(controlsBox, positioned: .above, relativeTo: nil)
        self.addSubview(functionsBox)
        
        controlsBox.setFrameOrigin(NSPoint.zero)
        
        moveInfoBoxTo(infoBoxDefaultPosition)
        functionsBox.hideIf(playbackState == .noTrack)
        
        if playbackState == .waiting {
            showGapFields()
        } else {
            gapBox.hide()
        }
    }
    
    fileprivate func moveInfoBoxTo(_ point: NSPoint) {
        
        infoBox.setFrameOrigin(point)
        gapBox.coLocate(infoBox)
        centerFunctionsBox()
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
        
        PlayerViewState.showTrackInfo = !PlayerViewState.showTrackInfo
        
        if PlayerViewState.showTrackInfo {
            
            infoBox.show()
            
        } else {
            
            infoBox.hide()
            
            PlayerViewState.showAlbumArt = true
            artView.show()
        }
    }
    
    func showOrHideSequenceInfo() {
        
        PlayerViewState.showSequenceInfo = !PlayerViewState.showSequenceInfo
        
//        [lblPlaybackScope, lblSequenceProgress, imgScope].forEach({$0?.showIf(PlayerViewState.showSequenceInfo)})
//        positionTrackInfoLabels()
    }
    
    func showOrHideAlbumArt() {
        
        PlayerViewState.showAlbumArt = !PlayerViewState.showAlbumArt
        
        if PlayerViewState.showAlbumArt {
            
            artView.show()
            
        } else {
            
            artView.hide()
            
            PlayerViewState.showTrackInfo = true
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
        return !PlayerViewState.showControls || !PlayerViewState.showTrackInfo
    }
    
    fileprivate func bringViewToFront(_ aView: NSView) {
        
        let superView = aView.superview
        aView.removeFromSuperview()
        superView?.addSubview(aView, positioned: .above, relativeTo: nil)
    }
    
    // MARK: Track info functions
    
    func showNowPlayingInfo(_ track: Track, _ playbackState: PlaybackState, _ sequence: (scope: SequenceScope, trackIndex: Int, totalTracks: Int)) {
        
        showPlayingTrackFields()
        
        // TODO:
        if (track.displayInfo.art != nil) {
            artView.image = track.displayInfo.art!
        } else {
            
            // Default artwork
            let playing = playbackState == .playing
            artView.image = playing ? Images.imgPlayingArt : Images.imgPausedArt
        }
    }
    
    func clearNowPlayingInfo() {
        
        // If gap is ongoing, end it
        if gapBox.isShown {
            gapBox.hide()
            // TODO: stop gap timer
        }
        
        // TODO:
        
        artView.image = Images.imgPausedArt
    }
    
    func sequenceChanged(_ sequence: (scope: SequenceScope, trackIndex: Int, totalTracks: Int)) {
        // TODO:
    }
    
    func gapStarted(_ msg: PlaybackGapStartedAsyncMessage) {
        
        showGapFields()
        
        let track = msg.nextTrack.track
        
        if (track.displayInfo.art != nil) {
            
            artView.image = track.displayInfo.art!
            
        } else {
            
            // Default artwork
            artView.image = Images.imgPausedArt
        }
        // TODO:
    }
    
    private func showGapFields() {
        
        gapBox.coLocate(infoBox)
        gapBox.show()
        [functionsBox, infoBox].forEach({$0?.hide()})
    }
    
    private func showPlayingTrackFields() {
        
        if gapBox.isShown {
            gapBox.hide()
        }
            
        // TODO: Also show info box if auto-hide-showing
        infoBox.showIf(PlayerViewState.showTrackInfo || autoHideFields_showing)
        functionsBox.showIf(PlayerViewState.showPlayingTrackFunctions)
    }
    
    func handOff(_ otherView: PlayerView) {
        
        // TODO: Handoff to gap view also
        
//        otherView.lblTrackName.stringValue = lblTrackName.stringValue
//        otherView.lblTrackTitle.stringValue = lblTrackTitle.stringValue
//        otherView.lblTrackArtist.stringValue = lblTrackArtist.stringValue
//        otherView.artView.image = artView.image
//        otherView.imgScope.image = imgScope.image
//        otherView.lblPlaybackScope.stringValue = lblPlaybackScope.stringValue
//        otherView.lblSequenceProgress.stringValue = lblSequenceProgress.stringValue
//
//        otherView.lblTrackName.showIf(lblTrackName.isShown)
//        otherView.lblTrackTitle.showIf(lblTrackTitle.isShown)
//        otherView.lblTrackArtist.showIf(lblTrackArtist.isShown)
//
//        otherView.positionTrackNameLabel()
//        otherView.positionScopeImage()
    }
}

@IBDesignable
class DefaultPlayerView: PlayerView {
    
    private let artViewDefaultPosition: NSPoint = NSPoint(x: 10, y: 83)
    
    private let artViewYCentered: CGFloat = 53
    
    override var infoBoxDefaultPosition: NSPoint { return NSPoint(x: 90, y: 70) }
    private let infoBoxCenteredPosition: NSPoint = NSPoint(x: 90, y: 40)
    
    override func showView(_ playbackState: PlaybackState) {
        
        super.showView(playbackState)
        
        PlayerViewState.showControls = true
        PlayerViewState.showPlayingTrackFunctions = true
        PlayerViewState.showAlbumArt = true
        PlayerViewState.showTrackInfo = true
        PlayerViewState.showSequenceInfo = true
        
        controlsBox.isTransparent = false

        artView.show()
        infoBox.show()
        
        // TODO:
//        [lblSequenceProgress, lblPlaybackScope, imgScope].forEach({$0?.show()})
        
        controlsBox.show()
    }
    
    override fileprivate func moveInfoBoxTo(_ point: NSPoint) {
        
        super.moveInfoBoxTo(point)
        artView.frame.origin.y = infoBox.frame.origin.y + 13
    }
    
    override func showOrHideMainControls() {
        
        super.showOrHideMainControls()
        
        // Re-position the info box, art view, and functions box
        moveInfoBoxTo(PlayerViewState.showControls ? infoBoxDefaultPosition : infoBoxCenteredPosition)
    }
    
    override func showOrHidePlayingTrackInfo() {
        // Do nothing (this function is not allowed on the default player view)
    }
    
    override func mouseEntered() {
        
        super.mouseEntered()
        
        if !PlayerViewState.showTrackInfo {
            autoHideInfo_show()
        }
        
        if !PlayerViewState.showControls {
            autoHideControls_show()
        }
    }
    
    override func mouseExited() {
        
        super.mouseExited()
        
        if !PlayerViewState.showTrackInfo {
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
        moveInfoBoxTo(infoBoxDefaultPosition)
    }
    
    private func autoHideControls_hide() {
        
        // Hide controls
        controlsBox.hide()
        moveInfoBoxTo(infoBoxCenteredPosition)
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
        PlayerViewState.showTrackInfo = true
        PlayerViewState.showSequenceInfo = true
        
        controlsBox.isTransparent = true
        
        artView.show()
        infoBox.show()
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
        
        if !PlayerViewState.showTrackInfo {
            autoHideInfo_show()
        }
    }
    
    override func mouseExited() {
        
        super.mouseExited()
        
        if !PlayerViewState.showTrackInfo {
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
        
        if !PlayerViewState.showTrackInfo {
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
        // TODO: Add a convenience func to PlaybackState enum to check if playing or paused
        if plState == .playing || plState == .paused {
            infoBox.show()
        }
        
        moveInfoBoxTo(infoBoxTopPosition)
    }
    
    private func autoHideControls_hide() {
        
        // Hide controls
        overlayBox.hide()
        controlsBox.hide()
        
        infoBox.isTransparent = false
        gapBox.isTransparent = false
        
        moveInfoBoxTo(infoBoxDefaultPosition)
        
        // Show info box as overlay temporarily
        if !PlayerViewState.showTrackInfo {
            infoBox.hide()
        }
    }
}
