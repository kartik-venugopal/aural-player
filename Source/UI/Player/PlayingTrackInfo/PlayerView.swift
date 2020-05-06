import Cocoa

@IBDesignable
class PlayerView: NSView, ColorSchemeable, TextSizeable {
    
    @IBOutlet weak var infoBox: NSBox!
    
    @IBOutlet weak var controlsBox: NSBox!
    @IBOutlet weak var functionsBox: NSBox!
    
    @IBOutlet weak var artView: NSImageView!
    
    @IBOutlet weak var textView: TrackInfoView!
    
    var trackInfo: PlayingTrackInfo? {
        
        didSet {
            trackInfoSet()
        }
    }
    
    fileprivate var controlsBoxPosition: NSPoint { return NSPoint(x: 0, y: 10) }
    fileprivate var infoBoxDefaultPosition: NSPoint { return NSPoint(x: 5, y: 60) }
    fileprivate var autoHideFields_showing: Bool = false
    
    func update() {
        trackInfoSet()
    }
    
    fileprivate func trackInfoSet() {
        
        textView.trackInfo = self.trackInfo
        artView.image = trackInfo?.art ?? Images.imgPlayingArt
        
        infoBox.showIf_elseHide(trackInfo != nil)
    }
    
    func showView() {
        
        self.addSubview(controlsBox, positioned: .above, relativeTo: nil)
        self.addSubview(functionsBox)
        
        controlsBox.setFrameOrigin(controlsBoxPosition)

        self.show()
    }
    
    func hideView() {
        
        self.hide()
        
        controlsBox.removeFromSuperview()
        functionsBox.removeFromSuperview()
    }
    
    fileprivate func moveInfoBoxTo(_ point: NSPoint) {
        
        infoBox.setFrameOrigin(point)
        centerFunctionsBox()
    }
    
    fileprivate func centerFunctionsBox() {
        
        // Vertically center functions box w.r.t. info box
        let funcY = infoBox.frame.minY + (infoBox.frame.height / 2) - (functionsBox.frame.height / 2) - 2
        functionsBox.setFrameOrigin(NSPoint(x: self.frame.width - functionsBox.frame.width - 5, y: funcY))
    }
    
    func showOrHidePlayingTrackInfo() {
        infoBox.showIf_elseHide(PlayerViewState.showTrackInfo)
    }
    
    func showOrHideSequenceInfo() {
//        infoView.showOrHideSequenceInfo()
    }
    
    func artUpdated() {
        artView.image = trackInfo?.art ?? Images.imgPlayingArt
    }
    
    func showOrHideAlbumArt() {
        artView.showIf_elseHide(PlayerViewState.showAlbumArt)
    }
    
    func showOrHideArtist() {
        textView.metadataDisplaySettingsChanged()
    }
    
    func showOrHideAlbum() {
        textView.metadataDisplaySettingsChanged()
    }
    
    func showOrHideCurrentChapter() {
        textView.metadataDisplaySettingsChanged()
    }
    
    func showOrHidePlayingTrackFunctions() {
        functionsBox.showIf_elseHide(PlayerViewState.showPlayingTrackFunctions)
    }
    
    func showOrHideMainControls() {
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
    
    func changeTextSize(_ size: TextSize) {
        textView.changeTextSize(size)
    }
    
    func applyColorScheme(_ scheme: ColorScheme) {
        
        changeBackgroundColor(scheme.general.backgroundColor)
        textView.applyColorScheme(scheme)
    }
    
    func changeBackgroundColor(_ color: NSColor) {

        // Solid color
        [infoBox, controlsBox, functionsBox].forEach({
            $0?.fillColor = color
            $0?.isTransparent = !color.isOpaque
        })
        
        // The art view's shadow color will depend on the window background color (it needs to have contrast relative to it).
        artView.layer?.shadowColor = color.visibleShadowColor.cgColor
    }
    
    func changePrimaryTextColor(_ color: NSColor) {
        textView.changeTextColor()
    }
    
    func changeSecondaryTextColor(_ color: NSColor) {
        textView.changeTextColor()
    }
    
    func changeTertiaryTextColor(_ color: NSColor) {
        textView.changeTextColor()
    }
}

@IBDesignable
class DefaultPlayerView: PlayerView {
    
    override var infoBoxDefaultPosition: NSPoint { return NSPoint(x: 85, y: 95) }
    private let infoBoxCenteredPosition: NSPoint = NSPoint(x: 85, y: 67)
    
    override func showView() {
        
        super.showView()

        moveInfoBoxTo(PlayerViewState.showControls ? infoBoxDefaultPosition : infoBoxCenteredPosition)
        
        artView.showIf_elseHide(PlayerViewState.showAlbumArt)
        controlsBox.showIf_elseHide(PlayerViewState.showControls)
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
    
    override var needsMouseTracking: Bool {
        return !PlayerViewState.showControls
    }
}

@IBDesignable
class ExpandedArtPlayerView: PlayerView {
    
    private let infoBoxTopPosition: NSPoint = NSPoint(x: 5, y: 90)
    @IBOutlet weak var overlayBox: NSBox!
    @IBOutlet weak var centerOverlayBox: NSBox!
    
    override func showView() {
        
        super.showView()
        
        moveInfoBoxTo(infoBoxDefaultPosition)
        
        NSView.hideViews(controlsBox, overlayBox)
        centerOverlayBox.showIf_elseHide(infoBox.isShown && !overlayBox.isShown)
        
        let windowColor = Colors.windowBackgroundColor
        [centerOverlayBox, overlayBox].forEach({$0?.fillColor = windowColor.clonedWithTransparency(overlayBox.fillColor.alphaComponent)})
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
        infoBox.show()
    }
    
    private func autoHideInfo_hide() {
        NSView.hideViews(infoBox, centerOverlayBox)
    }
    
    private func autoHideControls_show() {
        
        // Show controls
        NSView.showViews(controlsBox, overlayBox)
        centerOverlayBox.hide()
        
        controlsBox.makeTransparent()
        [infoBox, controlsBox, functionsBox].forEach({$0?.bringToFront()})
        
        // Re-position the info box, art view, and functions box
        moveInfoBoxTo(infoBoxTopPosition)
        infoBox.show()
    }
    
    private func autoHideControls_hide() {
        
        // Hide controls
        NSView.hideViews(overlayBox, controlsBox)
        centerOverlayBox.show()
        
        controlsBox.makeOpaque()
        moveInfoBoxTo(infoBoxDefaultPosition)
        
        // Show info box as overlay temporarily
        infoBox.hideIf(!PlayerViewState.showTrackInfo)
        centerOverlayBox.showIf_elseHide(infoBox.isShown && !overlayBox.isShown)
    }
    
    override func showOrHidePlayingTrackInfo() {
        
        super.showOrHidePlayingTrackInfo()
        centerOverlayBox.showIf_elseHide(infoBox.isShown && !overlayBox.isShown)
    }
    
    override var needsMouseTracking: Bool {
        return true
    }
    
    override func changeBackgroundColor(_ color: NSColor) {
        
        let windowColor = Colors.windowBackgroundColor
        [centerOverlayBox, overlayBox].forEach({$0?.fillColor = windowColor.clonedWithTransparency(overlayBox.fillColor.alphaComponent)})
        
        artView.layer?.shadowColor = Colors.windowBackgroundColor.visibleShadowColor.cgColor
    }
}
