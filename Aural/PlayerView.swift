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
    
    func showView() {
        
        print("Showing view: ", self.className)
        
        self.addSubview(playbackBox, positioned: .above, relativeTo: nil)
        self.addSubview(functionsBox)
        
        self.setNeedsDisplay(self.bounds)
        
        playbackBox.setFrameOrigin(NSPoint.zero)
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
        
        print(self.className, "hidden !")
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
    
    func mouseEntered() {
        print("Mouse Entered !")
    }
    
    func mouseExited() {
        print("Mouse Exited !")
    }
    
    private func bringViewToFront(_ aView: NSView) {
        
        let superView = aView.superview
        aView.removeFromSuperview()
        superView?.addSubview(aView, positioned: .above, relativeTo: nil)
    }
}

@IBDesignable
class DefaultPlayerView: PlayerView {
    
    private let artViewDefaultPosition: NSPoint = NSPoint(x: 10, y: 87)
    
    private let artViewXCentered: CGFloat = 215
    private let artViewYCentered: CGFloat = 52
    
    private let infoBoxDefaultPosition: NSPoint = NSPoint(x: 90, y: 75)
    private let infoBoxCenteredPosition: NSPoint = NSPoint(x: 90, y: 40)
    
    override func showView() {
        
        super.showView()
        
        // Position the info box
        playbackInfoBox.setFrameOrigin(infoBoxDefaultPosition)
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
}


@IBDesignable
class ExpandedArtPlayerView: PlayerView {
    
    private let infoBoxDefaultPosition: NSPoint = NSPoint(x: 0, y: 46)
    private let infoBoxTopPosition: NSPoint = NSPoint(x: 0, y: 81)
    
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
        
        // Center the info box
        playbackInfoBox.setFrameOrigin(infoBoxDefaultPosition)
    }
}
