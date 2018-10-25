import Cocoa

@IBDesignable
class PlayerView: NSView {
    
    @IBOutlet weak var playbackInfoBox: NSBox!
    @IBOutlet weak var playbackBox: NSBox!
    @IBOutlet weak var functionsBox: NSBox!
    
    @IBOutlet weak var lblTrackArtist: NSTextField!
    @IBOutlet weak var lblTrackTitle: NSTextField!
    @IBOutlet weak var lblTrackName: NSTextField!
    
    @IBOutlet weak var artView: NSImageView!
    
    // Fields that display information about the current playback scope
    @IBOutlet weak var lblSequenceProgress: NSTextField!
    @IBOutlet weak var lblPlaybackScope: NSTextField!
    @IBOutlet weak var imgScope: NSImageView!
    
    fileprivate var infoBoxDefaultPosition: NSPoint { return NSPoint(x: 0, y: 46) }
    
    func showView() {
        
        self.addSubview(playbackBox, positioned: .above, relativeTo: nil)
        self.addSubview(functionsBox)
        
        self.setNeedsDisplay(self.bounds)
        
        playbackBox.setFrameOrigin(NSPoint.zero)
        
        playbackInfoBox.setFrameOrigin(infoBoxDefaultPosition)
        centerFunctionsBox()
    }
    
    fileprivate func centerFunctionsBox() {
        
        // Vertically center functions box w.r.t. info box
        let funcY = playbackInfoBox.frame.minY + (playbackInfoBox.frame.height / 2) - (functionsBox.frame.height / 2)
        functionsBox.setFrameOrigin(NSPoint(x: self.frame.width - 5 - functionsBox.frame.width, y: funcY))
    }
    
    func hideView() {
        
        playbackBox.removeFromSuperview()
        functionsBox.removeFromSuperview()
    }
    
    func showOrHidePlayingTrackInfo() {
        
        PlayerViewState.showPlayingTrackInfo = !PlayerViewState.showPlayingTrackInfo
        
        if PlayerViewState.showPlayingTrackInfo {
            
            playbackInfoBox.isHidden = false
            
        } else {
            
            playbackInfoBox.isHidden = true
            
            PlayerViewState.showAlbumArt = true
            artView.isHidden = false
        }
    }
    
    func showOrHideAlbumArt() {
        
        PlayerViewState.showAlbumArt = !PlayerViewState.showAlbumArt
        
        if PlayerViewState.showAlbumArt {
            
            artView.isHidden = false
            
        } else {
            
            artView.isHidden = true
            
            PlayerViewState.showPlayingTrackInfo = true
            playbackInfoBox.isHidden = false
        }
    }
    
    func showOrHidePlayingTrackFunctions() {
        
        PlayerViewState.showPlayingTrackFunctions = !PlayerViewState.showPlayingTrackFunctions
        functionsBox.isHidden = !PlayerViewState.showPlayingTrackFunctions
    }
    
    func showOrHideMainControls() {
        
        PlayerViewState.showControls = !PlayerViewState.showControls
        playbackBox.isHidden = !PlayerViewState.showControls
    }
    
    func mouseEntered() {}
    
    func mouseExited() {}
    
    func needsMouseTracking() -> Bool {
        return !PlayerViewState.showControls || !PlayerViewState.showPlayingTrackInfo
    }
    
    fileprivate func bringViewToFront(_ aView: NSView) {
        
        let superView = aView.superview
        aView.removeFromSuperview()
        superView?.addSubview(aView, positioned: .above, relativeTo: nil)
    }
}

@IBDesignable
class DefaultPlayerView: PlayerView {
    
    private let artViewDefaultPosition: NSPoint = NSPoint(x: 10, y: 82)
    
    private let artViewXCentered: CGFloat = 215
    private let artViewYCentered: CGFloat = 52
    
    override var infoBoxDefaultPosition: NSPoint { return NSPoint(x: 90, y: 70) }
    private let infoBoxCenteredPosition: NSPoint = NSPoint(x: 90, y: 40)
    
    override func showView() {
        
        super.showView()
        
        // Position the art view
        artView.setFrameOrigin(artViewDefaultPosition)
        
        PlayerViewState.showControls = true
        PlayerViewState.showPlayingTrackFunctions = true
        PlayerViewState.showAlbumArt = true
        PlayerViewState.showPlayingTrackInfo = true

        artView.isHidden = false
        playbackInfoBox.isHidden = false
        playbackBox.isHidden = false
        functionsBox.isHidden = false
    }
    
    override func showOrHideMainControls() {
        
        super.showOrHideMainControls()
        
        // Re-position the info box, art view, and functions box
        playbackInfoBox.setFrameOrigin(PlayerViewState.showControls ? infoBoxDefaultPosition : infoBoxCenteredPosition)
        artView.frame.origin.y = PlayerViewState.showControls ? artViewDefaultPosition.y : artViewYCentered
        centerFunctionsBox()
    }
    
    override func showOrHidePlayingTrackInfo() {
        
        super.showOrHidePlayingTrackInfo()
        
        // Art view may need repositioning
        if PlayerViewState.showPlayingTrackInfo {
            
            artView.frame.origin.x = artViewDefaultPosition.x
            
        } else {
            
            playbackInfoBox.isHidden = true
            
            PlayerViewState.showAlbumArt = true
            artView.isHidden = false
            artView.frame.origin.x = artViewXCentered
        }
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
        
        playbackInfoBox.isTransparent = false
        playbackInfoBox.isHidden = false
    }
    
    private func autoHideInfo_hide() {
        
        playbackInfoBox.isTransparent = true
        playbackInfoBox.isHidden = true
    }
    
    private func autoHideControls_show() {
        
        // Show controls
        playbackBox.isHidden = false
        
        playbackInfoBox.setFrameOrigin(infoBoxDefaultPosition)
        artView.frame.origin.y = artViewDefaultPosition.y
        centerFunctionsBox()
    }
    
    private func autoHideControls_hide() {
        
        // Hide controls
        playbackBox.isHidden = true
        
        playbackInfoBox.setFrameOrigin(infoBoxCenteredPosition)
        artView.frame.origin.y = artViewYCentered
        centerFunctionsBox()
    }
}

@IBDesignable
class ExpandedArtPlayerView: PlayerView {
    
    private let infoBoxTopPosition: NSPoint = NSPoint(x: 0, y: 75)
    
    @IBOutlet weak var overlayBox: NSBox!
    
    override func showView() {
        
        super.showView()
        
        // Show/hide individual components
        PlayerViewState.showControls = false
        PlayerViewState.showPlayingTrackFunctions = true
        PlayerViewState.showAlbumArt = true
        PlayerViewState.showPlayingTrackInfo = true
        
        playbackBox.isHidden = true
        overlayBox.isHidden = true
        functionsBox.isHidden = false
        
        playbackInfoBox.isTransparent = false
    }
    
    override func showOrHideMainControls() {
        
        super.showOrHideMainControls()
        
        overlayBox.isHidden = !PlayerViewState.showControls
        [playbackInfoBox, playbackBox].forEach({$0?.isTransparent = !overlayBox.isHidden})
        
        [playbackInfoBox, playbackBox, functionsBox].forEach({self.bringViewToFront($0)})
        
        // Re-position the info box, art view, and functions box
        playbackInfoBox.setFrameOrigin(PlayerViewState.showControls ? infoBoxTopPosition : infoBoxDefaultPosition)
        centerFunctionsBox()
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
        
        playbackInfoBox.isTransparent = true
        playbackInfoBox.isHidden = false
    }
    
    private func autoHideInfo_hide() {
        
        playbackInfoBox.isTransparent = false
        playbackInfoBox.isHidden = true
    }
    
    private func autoHideControls_show() {
        
        // Show controls
        playbackBox.isHidden = false
        overlayBox.isHidden = false
        
        [playbackInfoBox, playbackBox].forEach({$0?.isTransparent = true})
        
        [playbackInfoBox, playbackBox, functionsBox].forEach({self.bringViewToFront($0)})
        
        // Re-position the info box, art view, and functions box
        playbackInfoBox.isHidden = false
        playbackInfoBox.setFrameOrigin(infoBoxTopPosition)
        centerFunctionsBox()
    }
    
    private func autoHideControls_hide() {
        
        // Hide controls
        overlayBox.isHidden = true
        playbackBox.isHidden = true
        
        playbackInfoBox.isTransparent = false
        
        playbackInfoBox.setFrameOrigin(infoBoxDefaultPosition)
        centerFunctionsBox()
        
        // Show info box as overlay temporarily
        if !PlayerViewState.showPlayingTrackInfo {
            playbackInfoBox.isHidden = true
        }
    }
}
