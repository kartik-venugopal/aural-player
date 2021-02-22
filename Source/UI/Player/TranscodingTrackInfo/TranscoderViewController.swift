import Cocoa

/*
    View controller for the subview within the player view that displays info about a track that is currently
    being transcoded, e.g. an Ogg Vorbis file.
 
    Displays transcoding progress, e.g. percentage transcoded, speed, and estimated time remaining.
*/
class TranscoderViewController: NSViewController, NotificationSubscriber {
    
    @IBOutlet weak var artView: NSImageView!
    @IBOutlet weak var overlayBox: NSBox!
    
    @IBOutlet weak var lblTrack: NSTextField!
    @IBOutlet weak var transcodingIcon: TintedImageView!
    
    @IBOutlet weak var lblTimeElapsed: NSTextField!
    @IBOutlet weak var lblTimeRemaining: NSTextField!
    
    @IBOutlet weak var progressView: ProgressArc!
    
    @IBOutlet weak var controlsBox: NSBox!
    private let controlsView: NSView = ViewFactory.controlsView
    
    @IBOutlet weak var functionsBox: NSBox!
    private let functionsView: NSView = ViewFactory.playingTrackFunctionsView
    
    @IBOutlet weak var containerBox: NSBox!
    
    private lazy var player: PlaybackDelegateProtocol = ObjectGraph.playbackDelegate
    
    override var nibName: String? {return "TranscodingTrack"}
    
    override func viewDidLoad() {
        
        transcodingIcon.tintFunction = {return Colors.functionButtonColor}
        
        applyFontScheme(FontSchemes.systemFontScheme)
        applyColorScheme(ColorSchemes.systemScheme)
        
        initSubscriptions()
    }
    
    private func initSubscriptions() {
        
        // Only respond if the transcoding track was updated
        Messenger.subscribeAsync(self, .player_trackInfoUpdated, self.transcodingTrackInfoUpdated(_:),
                                 filter: {msg in msg.updatedTrack == self.player.transcodingTrack &&
                                        msg.updatedFields.contains(.art) || msg.updatedFields.contains(.displayInfo)},
                                 queue: .main)
        
        Messenger.subscribeAsync(self, .player_trackTransitioned, self.trackTransitioned(_:),
                                 filter: {msg in msg.transcodingStarted},
                                 queue: .main)
        
        Messenger.subscribe(self, .applyFontScheme, self.applyFontScheme(_:))
        Messenger.subscribe(self, .applyColorScheme, self.applyColorScheme(_:))
        Messenger.subscribe(self, .changeBackgroundColor, self.changeBackgroundColor(_:))
        Messenger.subscribe(self, .changeFunctionButtonColor, self.changeFunctionButtonColor(_:))
        Messenger.subscribe(self, .player_changeSliderColors, self.changeSliderColors)
        Messenger.subscribe(self, .player_changeTrackInfoPrimaryTextColor, self.changePrimaryTextColor(_:))
        Messenger.subscribe(self, .player_changeTrackInfoSecondaryTextColor, self.changeSecondaryTextColor(_:))
        
        Messenger.subscribeAsync(self, .transcoder_progress, self.transcodingProgress(_:), queue: .main)
    }
    
    override func viewDidAppear() {
        
        DispatchQueue.main.async {
            
            if !self.controlsView.isDescendant(of: self.controlsBox) {
                self.controlsBox.addSubview(self.controlsView)
            }

            if !self.functionsView.isDescendant(of: self.functionsBox) {
                self.functionsBox.addSubview(self.functionsView)
            }

            self.functionsBox.showIf(PlayerViewState.showPlayingTrackFunctions)
        }
    }
    
    private func transcodingStarted(_ track: Track) {
        
        lblTrack.stringValue = track.conciseDisplayName
        artView.image = track.displayInfo.art?.image ?? Images.imgPlayingArt
        
        updateFields(0, 0, 0)
    }
    
    private func transcodingProgress(_ notification: TranscodingProgressNotification) {
        updateFields(notification.timeElapsed, notification.timeRemaining, notification.percentageTranscoded)
    }
    
    private func updateFields(_ timeElapsed: Double, _ timeRemaining: Double, _ percentage: Double) {
        
        let elapsed = ValueFormatter.formatSecondsToHMS(timeElapsed)
        let remaining = ValueFormatter.formatSecondsToHMS(timeRemaining)
        
        lblTimeElapsed.stringValue = String(format: "Time elapsed:   %@", elapsed)
        lblTimeRemaining.stringValue = String(format: "Time remaining:   %@", remaining)
        
        progressView.percentage = percentage
    }
    
    func transcodingTrackInfoUpdated(_ notification: TrackInfoUpdatedNotification) {

        let track = notification.updatedTrack
        
        lblTrack.stringValue = track.conciseDisplayName
        artView.image = track.displayInfo.art?.image ?? Images.imgPlayingArt
    }

    // MARK: Appearance
    
    private func applyFontScheme(_ fontScheme: FontScheme) {
        
        lblTrack.font = FontSchemes.systemFontScheme.player.infoBoxTitleFont
        [lblTimeElapsed, lblTimeRemaining].forEach({$0?.font = FontSchemes.systemFontScheme.player.trackTimesFont})
    }
    
    private func applyColorScheme(_ scheme: ColorScheme) {
        
        changeBackgroundColor(scheme.general.backgroundColor)
        changeFunctionButtonColor(scheme.general.functionButtonColor)
        
        changePrimaryTextColor(scheme.player.trackInfoPrimaryTextColor)
        changeSecondaryTextColor(scheme.player.trackInfoSecondaryTextColor)
    }
    
    private func changeBackgroundColor(_ color: NSColor) {
        
        containerBox.fillColor = color
        containerBox.isTransparent = !color.isOpaque
        
        overlayBox.fillColor = color.clonedWithTransparency(overlayBox.fillColor.alphaComponent)
        artView.layer?.shadowColor = color.visibleShadowColor.cgColor
    }
    
    private func changeFunctionButtonColor(_ color: NSColor) {
        transcodingIcon.reTint()
    }
    
    private func changePrimaryTextColor(_ color: NSColor) {
        lblTrack.textColor = Colors.Player.trackInfoTitleTextColor
    }
    
    private func changeSecondaryTextColor(_ color: NSColor) {
        
        [lblTimeElapsed, lblTimeRemaining].forEach({
            $0?.textColor = Colors.Player.trackInfoArtistAlbumTextColor
        })
        
        progressView.redraw()
    }
    
    private func changeSliderColors() {
        progressView.redraw()
    }
    
    // MARK: Message handling
    
    func trackTransitioned(_ notification: TrackTransitionNotification) {
        
        if let track = notification.endTrack {
            transcodingStarted(track)
        }
    }
}
