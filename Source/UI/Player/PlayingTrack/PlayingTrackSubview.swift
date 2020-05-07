import Cocoa

@IBDesignable
class PlayingTrackSubview: NSView, ColorSchemeable, TextSizeable {
    
    @IBOutlet weak var infoBox: NSBox!
    @IBOutlet weak var artView: NSImageView!
    @IBOutlet weak var textView: PlayingTrackTextView!
    
    @IBOutlet weak var controlsBox: NSBox!
    private let controlsView: NSView = ViewFactory.controlsView
    
    @IBOutlet weak var functionsBox: NSBox!
    private let functionsView: NSView = ViewFactory.playingTrackFunctionsView
    
    fileprivate var autoHideFields_showing: Bool = false
    
    var trackInfo: PlayingTrackInfo? {
        
        didSet {
            trackInfoSet()
        }
    }
    
    func showView() {
        
        controlsView.removeFromSuperview()
        controlsBox.addSubview(controlsView)
        
        functionsView.removeFromSuperview()
        functionsBox.addSubview(functionsView)
        
        show()
    }
    
    func hideView() {
        hide()
    }
    
    func update() {
        trackInfoSet()
    }
    
    fileprivate func trackInfoSet() {
        
        textView.trackInfo = self.trackInfo
        artView.image = trackInfo?.art ?? Images.imgPlayingArt
    }

    fileprivate func moveInfoBoxTo(_ point: NSPoint) {
        
        infoBox.setFrameOrigin(point)
        
        // Vertically center functions box w.r.t. info box
        functionsBox.frame.origin.y = infoBox.frame.minY
    }
    
    func showOrHidePlayingTrackInfo() {
        infoBox.showIf(PlayerViewState.showTrackInfo || autoHideFields_showing)
    }
    
    func showOrHideAlbumArt() {
        artView.showIf(PlayerViewState.showAlbumArt)
    }
    
    func showOrHideArtist() {
        textView.displayedTextChanged()
    }
    
    func showOrHideAlbum() {
        textView.displayedTextChanged()
    }
    
    func showOrHideCurrentChapter() {
        textView.displayedTextChanged()
    }
    
    func showOrHidePlayingTrackFunctions() {
        functionsBox.showIf(PlayerViewState.showPlayingTrackFunctions)
    }
    
    func showOrHideMainControls() {
        controlsBox.showIf(PlayerViewState.showControls)
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
    
    // MARK: Appearance functions
    
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
class DefaultPlayerView: PlayingTrackSubview {
    
    private let infoBoxDefaultPosition: NSPoint = NSPoint(x: 90, y: 95)
    private let infoBoxCenteredPosition: NSPoint = NSPoint(x: 90, y: 70)
    
    override var needsMouseTracking: Bool {
        return !PlayerViewState.showControls
    }
    
    override func awakeFromNib() {
    
        moveInfoBoxTo(PlayerViewState.showControls ? infoBoxDefaultPosition : infoBoxCenteredPosition)
        
        artView.showIf(PlayerViewState.showAlbumArt)
        controlsBox.showIf(PlayerViewState.showControls)
        functionsBox.showIf(PlayerViewState.showPlayingTrackFunctions)
    }
    
    override fileprivate func moveInfoBoxTo(_ point: NSPoint) {
        
        super.moveInfoBoxTo(point)
        artView.frame.origin.y = infoBox.frame.origin.y + 5 // 5 is half the difference in height between infoBox and artView
    }
    
    override func showOrHideMainControls() {
        
        super.showOrHideMainControls()
        
        // Re-position the info box, art view, and functions box
        moveInfoBoxTo(PlayerViewState.showControls ? infoBoxDefaultPosition : infoBoxCenteredPosition)
    }
    
    // Do nothing (this function is not allowed on the default player view)
    override func showOrHidePlayingTrackInfo() {}
    
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
}

@IBDesignable
class ExpandedArtPlayerView: PlayingTrackSubview {
    
    private let infoBoxDefaultPosition: NSPoint = NSPoint(x: 30, y: 70)
    private let infoBoxTopPosition: NSPoint = NSPoint(x: 30, y: 95)
    
    @IBOutlet weak var overlayBox: NSBox!
    @IBOutlet weak var centerOverlayBox: NSBox!
    
    override var needsMouseTracking: Bool {
        return true
    }
    
    override func awakeFromNib() {

        moveInfoBoxTo(infoBoxDefaultPosition)

        NSView.hideViews(controlsBox, overlayBox)
        
        infoBox.showIf(PlayerViewState.showTrackInfo)
        centerOverlayBox.showIf(infoBox.isShown)
        
        functionsBox.showIf(PlayerViewState.showPlayingTrackFunctions)
    }
    
    // Do nothing (this function is not allowed on the expanded art player view)
    override func showOrHideMainControls() {}

    // Do nothing (this function is not allowed on the expanded art player view)
    override func showOrHideAlbumArt() {}
    
    override func mouseEntered() {
        
        super.mouseEntered()
        autoHideControls_show()
    }
    
    override func mouseExited() {
        
        super.mouseExited()
        autoHideControls_hide()
    }
    
    private func autoHideControls_show() {
        
        // Show controls
        NSView.showViews(controlsBox, overlayBox)
        centerOverlayBox.hide()
        
        [infoBox, controlsBox, functionsBox].forEach({$0?.bringToFront()})
        
        // Re-position the info box and functions box
        moveInfoBoxTo(infoBoxTopPosition)
        infoBox.show()
    }
    
    private func autoHideControls_hide() {
        
        // Hide controls
        NSView.hideViews(overlayBox, controlsBox)
        
        // Show info box only if the setting allows it.
        infoBox.showIf(PlayerViewState.showTrackInfo)
        centerOverlayBox.showIf(infoBox.isShown)
        
        moveInfoBoxTo(infoBoxDefaultPosition)
    }
    
    override func showOrHidePlayingTrackInfo() {
        
        super.showOrHidePlayingTrackInfo()
        centerOverlayBox.showIf(infoBox.isShown && !overlayBox.isShown)
    }
    
    override func changeBackgroundColor(_ color: NSColor) {
        
        let windowColorWithTransparency = Colors.windowBackgroundColor.clonedWithTransparency(overlayBox.fillColor.alphaComponent)
        [centerOverlayBox, overlayBox].forEach({$0?.fillColor = windowColorWithTransparency})
        
        artView.layer?.shadowColor = Colors.windowBackgroundColor.visibleShadowColor.cgColor
    }
    
    override func trackInfoSet() {

        super.trackInfoSet()
        infoBox.showIf(trackInfo != nil && (PlayerViewState.showTrackInfo || autoHideFields_showing))
    }
}
