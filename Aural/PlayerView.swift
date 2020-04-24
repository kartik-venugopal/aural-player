import Cocoa

@IBDesignable
class PlayerView: NSView {
    
    @IBOutlet weak var infoBox: NSBox!
    @IBOutlet weak var controlsBox: NSBox!
    @IBOutlet weak var functionsBox: NSBox!
    @IBOutlet weak var gapBox: NSBox!
    @IBOutlet weak var artView: NSImageView!
    
    @IBOutlet weak var infoView: TrackInfoView!
    @IBOutlet weak var gapView: GapView!
    
    fileprivate let player: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    fileprivate var infoBoxDefaultPosition: NSPoint { return NSPoint(x: 0, y: 47) }
    fileprivate var autoHideFields_showing: Bool = false
    
    func showView(_ playbackState: PlaybackState) {
        
        self.addSubview(controlsBox, positioned: .above, relativeTo: nil)
        self.addSubview(functionsBox)
        
        controlsBox.setFrameOrigin(NSPoint.zero)

        gapView.showView(playbackState)
        
        playbackState == .waiting ? showGapInfo() : showPlayingTrackInfo()
    }
    
    fileprivate func moveInfoBoxTo(_ point: NSPoint) {
        
        infoBox.setFrameOrigin(point)
        gapBox.coLocate(infoBox)
        centerFunctionsBox()
    }
    
    fileprivate func centerFunctionsBox() {
        
        // Vertically center functions box w.r.t. info box
        let funcY = infoBox.frame.minY + (infoBox.frame.height / 2) - (functionsBox.frame.height / 2) - 2
        functionsBox.setFrameOrigin(NSPoint(x: self.frame.width - functionsBox.frame.width - 5, y: funcY))
    }
    
    func hideView() {
        
        controlsBox.removeFromSuperview()
        functionsBox.removeFromSuperview()
    }
    
    func showOrHidePlayingTrackInfo() {
        
        PlayerViewState.showTrackInfo = !PlayerViewState.showTrackInfo
        infoBox.showIf_elseHide(PlayerViewState.showTrackInfo)
    }
    
    func showOrHideSequenceInfo() {
//        infoView.showOrHideSequenceInfo()
    }
    
    func showOrHideAlbumArt() {
        
        PlayerViewState.showAlbumArt = !PlayerViewState.showAlbumArt
        artView.showIf_elseHide(PlayerViewState.showAlbumArt)
    }
    
    func showOrHideArtist() {
        
        PlayerViewState.showArtist = !PlayerViewState.showArtist
        infoView.metadataDisplaySettingsChanged()
    }
    
    func showOrHideAlbum() {
        
        PlayerViewState.showAlbum = !PlayerViewState.showAlbum
        infoView.metadataDisplaySettingsChanged()
    }
    
    func showOrHideCurrentChapter() {
        
        PlayerViewState.showCurrentChapter = !PlayerViewState.showCurrentChapter
        infoView.metadataDisplaySettingsChanged()
    }
    
    func showOrHidePlayingTrackFunctions() {
        
        PlayerViewState.showPlayingTrackFunctions = !PlayerViewState.showPlayingTrackFunctions
        functionsBox.showIf_elseHide(PlayerViewState.showPlayingTrackFunctions)
    }
    
    func showOrHideMainControls() {
        
        PlayerViewState.showControls = !PlayerViewState.showControls
        controlsBox.showIf_elseHide(PlayerViewState.showControls)
    }
    
    func mouseEntered() {
        autoHideFields_showing = true
    }
    
    func mouseExited() {
        autoHideFields_showing = false
    }
    
    var needsMouseTracking: Bool {
        return false
    }
    
    // MARK: Track info functions
    
    func showNowPlayingInfo(_ track: Track, _ playbackState: PlaybackState, _ sequence: (scope: SequenceScope, trackIndex: Int, totalTracks: Int), _ chapterTitle: String?) {
        
        infoView.showNowPlayingInfo(track, sequence, chapterTitle)
        showPlayingTrackInfo()
        
        artView.image = track.displayInfo.art?.image ?? Images.imgPlayingArt
    }
    
    func setPlayingInfo_dontShow(_ track: Track, _ sequence: (scope: SequenceScope, trackIndex: Int, totalTracks: Int)) {
        
        infoView.showNowPlayingInfo(track, sequence, nil)
        artView.image = track.displayInfo.art?.image ?? Images.imgPlayingArt
    }
    
    func clearNowPlayingInfo() {
        
        infoView.clearNowPlayingInfo()
        showPlayingTrackInfo()
        
        artView.image = Images.imgPlayingArt
    }
    
    func chapterChanged(_ chapterTitle: String?) {
        infoView.chapterChanged(chapterTitle)
    }
    
    func sequenceChanged(_ sequence: (scope: SequenceScope, trackIndex: Int, totalTracks: Int)) {
//        infoView.sequenceChanged(sequence)
    }
    
    func gapStarted(_ msg: PlaybackGapStartedAsyncMessage) {
        
        makeOpaque(gapBox)
        showGapInfo()
        
        let track = msg.nextTrack.track
        artView.image = track.displayInfo.art?.image ?? Images.imgPlayingArt
        
        gapView.gapStarted(msg)
    }
    
    fileprivate func showGapInfo() {
        
        gapBox.coLocate(infoBox)
        gapBox.show()
        hideViews(infoBox, functionsBox)
    }
    
    fileprivate func showPlayingTrackInfo() {
        
        if gapBox.isShown {
            
            gapBox.hide()
            gapView.endGap()
        }
        
        infoBox.showIf_elseHide(player.state.playingOrPaused() && (PlayerViewState.showTrackInfo || autoHideFields_showing))
        functionsBox.showIf_elseHide(player.state.playingOrPaused() && PlayerViewState.showPlayingTrackFunctions)
    }
    
    func handOff(_ otherView: PlayerView) {
        
        infoView.handOff(otherView.infoView)
        gapView.handOff(otherView.gapView)
        otherView.artView.image = artView.image
    }
    
    func changeTextSize() {
        
        infoView.changeTextSize()
        gapView.changeTextSize()
    }
    
    func changeBackgroundColor(_ color: NSColor) {

        // Solid color
        [infoBox, controlsBox, functionsBox, gapBox].forEach({
            $0?.fillColor = color
            $0?.isTransparent = !color.isOpaque
        })
    }
    
    func changePrimaryTextColor(_ color: NSColor) {
        
        infoView.changeTextColor()
        gapView.changeTextColor()
    }
    
    func changeSecondaryTextColor(_ color: NSColor) {
        
        infoView.changeTextColor()
        gapView.changeTextColor()
    }
    
    func changeTertiaryTextColor(_ color: NSColor) {
        
        infoView.changeTextColor()
        gapView.changeTextColor()
    }
}

@IBDesignable
class DefaultPlayerView: PlayerView {
    
    override var infoBoxDefaultPosition: NSPoint { return NSPoint(x: 80, y: 85) }
    private let infoBoxCenteredPosition: NSPoint = NSPoint(x: 80, y: 52)
    
    override func awakeFromNib() {
        artView.cornerRadius = 2
    }
    
    override func showView(_ playbackState: PlaybackState) {
        
        super.showView(playbackState)

        moveInfoBoxTo(PlayerViewState.showControls ? infoBoxDefaultPosition : infoBoxCenteredPosition)
        
        artView.showIf_elseHide(PlayerViewState.showAlbumArt)
        controlsBox.showIf_elseHide(PlayerViewState.showControls)
        
        playbackState == .waiting ? showGapInfo() : showPlayingTrackInfo()
    }
    
    override fileprivate func moveInfoBoxTo(_ point: NSPoint) {
        
        super.moveInfoBoxTo(point)
        artView.frame.origin.y = infoBox.frame.origin.y + 5
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
        
        if !PlayerViewState.showControls {
            autoHideControls_show()
        }
    }
    
    override func mouseExited() {
        
        super.mouseExited()
        
        if !PlayerViewState.showControls {
            autoHideControls_hide()
        }
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
    
    override fileprivate func showPlayingTrackInfo() {
        
        super.showPlayingTrackInfo()
        infoBox.show()
    }
    
    override var needsMouseTracking: Bool {
        return !PlayerViewState.showControls
    }
}

@IBDesignable
class ExpandedArtPlayerView: PlayerView {
    
    private let infoBoxTopPosition: NSPoint = NSPoint(x: 0, y: 80)
    @IBOutlet weak var overlayBox: NSBox!
    @IBOutlet weak var centerOverlayBox: NSBox!
    
    override func awakeFromNib() {
        artView.cornerRadius = 5
    }
    
    override func showView(_ playbackState: PlaybackState) {
        
        super.showView(playbackState)
        
        moveInfoBoxTo(infoBoxDefaultPosition)
        
        hideViews(controlsBox, overlayBox)
        centerOverlayBox.showIf_elseHide(infoBox.isShown)
        
        playbackState == .waiting ? showGapInfo() : showPlayingTrackInfo()
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
        
        makeTransparent(gapBox)
        infoBox.showIf_elseHide(player.state.playingOrPaused())
    }
    
    private func autoHideInfo_hide() {
        
        makeOpaque(gapBox)
        hideViews(infoBox, centerOverlayBox)
    }
    
    private func autoHideControls_show() {
        
        // Show controls
        showViews(controlsBox, overlayBox)
        centerOverlayBox.hide()
        
        makeTransparent(controlsBox, gapBox)
        [infoBox, controlsBox, functionsBox, gapBox].forEach({bringViewToFront($0)})
        
        // Re-position the info box, art view, and functions box
        moveInfoBoxTo(infoBoxTopPosition)
        infoBox.showIf_elseHide(player.state.playingOrPaused())
    }
    
    private func autoHideControls_hide() {
        
        // Hide controls
        hideViews(overlayBox, controlsBox)
        centerOverlayBox.show()
        
        makeOpaque(controlsBox, gapBox)
        moveInfoBoxTo(infoBoxDefaultPosition)
        
        // Show info box as overlay temporarily
        infoBox.hideIf(!PlayerViewState.showTrackInfo)
        centerOverlayBox.showIf_elseHide(infoBox.isShown)
    }
    
    override func clearNowPlayingInfo() {
        
        infoView.clearNowPlayingInfo()
        
        // Need to hide info box because it is opaque and will obscure art
        hideViews(infoBox, centerOverlayBox)
        artView.image = Images.imgPlayingArt
    }
    
    override fileprivate func showPlayingTrackInfo() {
        
        super.showPlayingTrackInfo()
        centerOverlayBox.showIf_elseHide(infoBox.isShown)
    }
    
    override func showOrHidePlayingTrackInfo() {
        
        super.showOrHidePlayingTrackInfo()
        centerOverlayBox.showIf_elseHide(infoBox.isShown)
    }
    
    override var needsMouseTracking: Bool {
        return true
    }
    
    override func changeBackgroundColor(_ color: NSColor) {
        // Do nothing
    }
}

fileprivate func showViews(_ views: NSView...) {
    views.forEach({$0.show()})
}

fileprivate func hideViews(_ views: NSView...) {
    views.forEach({$0.hide()})
}

fileprivate func makeTransparent(_ boxes: NSBox...) {
    boxes.forEach({$0.isTransparent = true})
}

fileprivate func makeOpaque(_ boxes: NSBox...) {
    boxes.forEach({$0.isTransparent = false})
}

fileprivate func bringViewToFront(_ aView: NSView) {
    
    let superView = aView.superview
    aView.removeFromSuperview()
    superView?.addSubview(aView, positioned: .above, relativeTo: nil)
}
