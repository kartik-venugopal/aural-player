//
//  PlayingTrackSubview.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    A base class for the 2 player views - Default and Expanded Art
 */
@IBDesignable
class PlayingTrackSubview: NSView, ColorSchemeable {
    
    @IBOutlet weak var infoBox: NSBox!
    @IBOutlet weak var artView: NSImageView!
    @IBOutlet weak var textView: PlayingTrackTextView!
    
    @IBOutlet weak var controlsBox: NSBox!
    @IBOutlet weak var functionsBox: NSBox!
    
    fileprivate var autoHideFields_showing: Bool = false
    
    fileprivate lazy var uiState: PlayerUIState = objectGraph.playerUIState
    
    var trackInfo: PlayingTrackInfo? {
        
        didSet {
            trackInfoSet()
        }
    }
    
    func showView() {
    }
    
    func hideView() {
    }
    
    func update() {
        trackInfoSet()
    }
    
    fileprivate var functionButtons: [NSButton] = []
    
    override func awakeFromNib() {
        functionButtons = functionsBox.subviews[0].subviews.compactMap {$0 as? NSButton}
    }
    
    fileprivate func trackInfoSet() {
        
        textView.trackInfo = self.trackInfo
        artView.image = trackInfo?.art ?? Images.imgPlayingArt
        functionButtons.forEach {$0.showIf(trackInfo != nil && uiState.showPlayingTrackFunctions)}
    }

    fileprivate func moveInfoBoxTo(_ point: NSPoint) {
        
        infoBox.setFrameOrigin(point)
        
        // Vertically center functions box w.r.t. info box
        functionsBox.frame.origin.y = infoBox.frame.minY
    }
    
    func showOrHidePlayingTrackInfo() {
        infoBox.showIf(uiState.showTrackInfo || autoHideFields_showing)
    }
    
    func showOrHideAlbumArt() {
        artView.showIf(uiState.showAlbumArt)
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
        functionButtons.forEach {$0.showIf(trackInfo != nil && uiState.showPlayingTrackFunctions)}
    }
    
    func showOrHideMainControls() {
        controlsBox.showIf(uiState.showControls)
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
    
    func applyFontScheme(_ fontScheme: FontScheme) {
        textView.applyFontScheme(fontScheme)
    }
    
    func applyColorScheme(_ scheme: ColorScheme) {
        
        changeBackgroundColor(scheme.general.backgroundColor)
        textView.applyColorScheme(scheme)
    }
    
    func changeBackgroundColor(_ color: NSColor) {

        // Solid color
        [infoBox, functionsBox].forEach {
            $0?.fillColor = color
        }
        
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

/*
   The "Default" player view.
*/
@IBDesignable
class DefaultPlayingTrackSubview: PlayingTrackSubview {
    
    private let infoBoxDefaultPosition: NSPoint = NSPoint(x: 90, y: 100)
    private let infoBoxCenteredPosition: NSPoint = NSPoint(x: 90, y: 70)
    
    override var needsMouseTracking: Bool {
        return !uiState.showControls
    }
    
    override func showView() {

        super.showView()
        
        artView.showIf(uiState.showAlbumArt)
        functionButtons.forEach {$0.showIf(trackInfo != nil && uiState.showPlayingTrackFunctions)}
        moveInfoBoxTo(uiState.showControls ? infoBoxDefaultPosition : infoBoxCenteredPosition)

        controlsBox.showIf(uiState.showControls)
        controlsBox.bringToFront()
    }
    
    override fileprivate func moveInfoBoxTo(_ point: NSPoint) {
        
        super.moveInfoBoxTo(point)
        artView.frame.origin.y = infoBox.frame.origin.y // 5 is half the difference in height between infoBox and artView
    }
    
    override func showOrHideMainControls() {
        
        super.showOrHideMainControls()
        
        // Re-position the info box, art view, and functions box
        moveInfoBoxTo(uiState.showControls ? infoBoxDefaultPosition : infoBoxCenteredPosition)
    }
    
    // Do nothing (this function is not allowed on the default player view)
    override func showOrHidePlayingTrackInfo() {}
    
    override func mouseEntered() {
        
        super.mouseEntered()
        
        if !uiState.showControls {
            autoHideControls_show()
        }
    }
    
    override func mouseExited() {
        
        super.mouseExited()
        
        if !uiState.showControls {
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

/*
   The "Expanded Art" player view.
*/
@IBDesignable
class ExpandedArtPlayingTrackSubview: PlayingTrackSubview {
    
    private let infoBoxDefaultPosition: NSPoint = NSPoint(x: 30, y: 65)
    private let infoBoxTopPosition: NSPoint = NSPoint(x: 30, y: 95)
    
    // Overlay boxes that provide a background so that text and controls are legible when displayed over the album art.
    @IBOutlet weak var overlayBox: NSBox!
    @IBOutlet weak var centerOverlayBox: NSBox!
    
    override var needsMouseTracking: Bool {
        return true
    }
    
    override func showView() {

        super.showView()
        
        moveInfoBoxTo(infoBoxDefaultPosition)

        NSView.hideViews(controlsBox, overlayBox)
        
        infoBox.showIf(trackInfo != nil && uiState.showTrackInfo)
        centerOverlayBox.showIf(infoBox.isShown)
        
        infoBox.bringToFront()
        controlsBox.bringToFront()

        functionButtons.forEach {$0.showIf(trackInfo != nil && uiState.showPlayingTrackFunctions)}
        moveInfoBoxTo(infoBoxDefaultPosition)
    }
    
    override func trackInfoSet() {

        super.trackInfoSet()
        showOrHidePlayingTrackInfo()
    }
    
    // Do nothing (this function is not allowed on the expanded art player view)
    override func showOrHideMainControls() {}

    // Do nothing (this function is not allowed on the expanded art player view)
    override func showOrHideAlbumArt() {}
    
    override func showOrHidePlayingTrackInfo() {
        
        infoBox.showIf(trackInfo != nil && (uiState.showTrackInfo || autoHideFields_showing))
        centerOverlayBox.showIf(infoBox.isShown && !overlayBox.isShown)
        
        infoBox.bringToFront()
        controlsBox.bringToFront()
    }
    
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
        
        // Re-position the info box and functions box
        moveInfoBoxTo(infoBoxTopPosition)
        infoBox.showIf(trackInfo != nil)
        
        infoBox.bringToFront()
        controlsBox.bringToFront()
    }
    
    private func autoHideControls_hide() {
        
        // Hide controls
        NSView.hideViews(overlayBox, controlsBox)
        
        // Show info box only if the setting allows it.
        infoBox.showIf(trackInfo != nil && uiState.showTrackInfo)
        centerOverlayBox.showIf(infoBox.isShown)
        
        infoBox.bringToFront()
        controlsBox.bringToFront()
        
        moveInfoBoxTo(infoBoxDefaultPosition)
    }
    
    override func changeBackgroundColor(_ color: NSColor) {
        
        let windowColorWithTransparency = color.clonedWithTransparency(overlayBox.fillColor.alphaComponent)
        [centerOverlayBox, overlayBox].forEach {$0?.fillColor = windowColorWithTransparency}
        
        artView.layer?.shadowColor = color.visibleShadowColor.cgColor
    }
}
