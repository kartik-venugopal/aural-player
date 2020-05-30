import Cocoa

class TranscoderViewController: NSViewController, AsyncMessageSubscriber, MessageSubscriber, ActionMessageSubscriber {
    
    @IBOutlet weak var artView: NSImageView!
    @IBOutlet weak var overlayBox: NSBox!
    
    @IBOutlet weak var lblTrack: NSTextField!
    @IBOutlet weak var transcodingIcon: TintedImageView!
    @IBOutlet weak var btnCancel: NSButton!
    
    @IBOutlet weak var lblTrackTime: NSTextField!
    @IBOutlet weak var lblTimeElapsed: NSTextField!
    @IBOutlet weak var lblTimeRemaining: NSTextField!
    @IBOutlet weak var lblSpeed: NSTextField!
    
    @IBOutlet weak var lblTranscoding: NSTextField!
    
    @IBOutlet weak var progressView: ProgressArc!
    
    @IBOutlet weak var containerBox: NSBox!
    
    private lazy var player: PlaybackDelegateProtocol = ObjectGraph.playbackDelegate
    
    override var nibName: String? {return "TranscodingTrack"}
    
    override func viewDidLoad() {
        
        transcodingIcon.tintFunction = {return Colors.functionButtonColor}
        
        changeTextSize(PlayerViewState.textSize)
        applyColorScheme(ColorSchemes.systemScheme)
        
        initSubscriptions()
    }
    
    private func initSubscriptions() {
        
        SyncMessenger.subscribe(messageTypes: [.playingTrackInfoUpdatedNotification], subscriber: self)
        
        SyncMessenger.subscribe(actionTypes: [.changePlayerView, .showOrHideAlbumArt, .showOrHideArtist, .showOrHideAlbum, .showOrHideCurrentChapter, .showOrHideMainControls, .showOrHidePlayingTrackInfo, .showOrHideSequenceInfo, .showOrHidePlayingTrackFunctions, .changePlayerTextSize, .applyColorScheme, .changeBackgroundColor, .changePlayerTrackInfoPrimaryTextColor, .changePlayerTrackInfoSecondaryTextColor], subscriber: self)
        
        AsyncMessenger.subscribe([.transcodingStarted, .transcodingProgress, .transcodingCancelled, .transcodingFinished], subscriber: self, dispatchQueue: DispatchQueue.main)
    }
    
    private func transcodingStarted(_ track: Track) {
        
        lblTrack.stringValue = track.conciseDisplayName
        artView.image = track.displayInfo.art?.image ?? Images.imgPlayingArt
        
        updateFields(0, track.duration, 0, 0, 0, "0x")
    }
    
    private func transcodingProgress(_ msg: TranscodingProgressAsyncMessage) {
        
        updateFields(msg.timeTranscoded, msg.track.duration, msg.timeElapsed, msg.timeRemaining, msg.percTranscoded, msg.speed)
    }
    
    private func transcodingFinished() {
        // TODO - Do we even need this method ???
    }
    
    private func transcodingCancelled() {
        transcodingFinished()
    }
    
    private func updateFields(_ timeTranscoded: Double, _ trackDuration: Double, _ timeElapsed: Double, _ timeRemaining: Double, _ percentage: Double, _ speed: String) {
        
        let trackTime = ValueFormatter.formatSecondsToHMS(timeTranscoded)
        let trackDuration = ValueFormatter.formatSecondsToHMS(trackDuration)
        
        let elapsed = ValueFormatter.formatSecondsToHMS(timeElapsed)
        let remaining = ValueFormatter.formatSecondsToHMS(timeRemaining)
        
        lblTrackTime.stringValue = String(format: "Track time:   %@  /  %@", trackTime, trackDuration)
        lblTimeElapsed.stringValue = String(format: "Time elapsed:   %@", elapsed)
        lblTimeRemaining.stringValue = String(format: "Time remaining:   %@", remaining)
        lblSpeed.stringValue = String(format: "Speed:   %@", speed)
        
        progressView.percentage = percentage
    }
    
    private func updateTrackInfo(_ track: Track) {

        lblTrack.stringValue = track.conciseDisplayName
        artView.image = track.displayInfo.art?.image ?? Images.imgPlayingArt
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        
        player.stop()
        transcodingFinished()
    }

    // MARK: Appearance
    
    private func changeTextSize(_ size: TextSize) {
        
        lblTrack.font = Fonts.Player.infoBoxTitleFont
        [lblTrackTime, lblTimeElapsed, lblTimeRemaining, lblSpeed].forEach({$0?.font = Fonts.Player.trackTimesFont})
        lblTranscoding.font = Fonts.Player.infoBoxArtistAlbumFont
    }
    
    private func applyColorScheme(_ scheme: ColorScheme) {
        
        changeBackgroundColor(scheme.general.backgroundColor)
        changeFunctionButtonColor(scheme.general.functionButtonColor)
        changeTextButtonColor()
        
        changePrimaryTextColor()
        changeSecondaryTextColor()
        
        changeSliderColors()
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
    
    private func changeTextButtonColor() {
        btnCancel.redraw()
    }
    
    private func changeButtonTextColor() {
        btnCancel.redraw()
    }
    
    private func changePrimaryTextColor() {
        
        lblTrack.textColor = Colors.Player.trackInfoTitleTextColor
        lblTranscoding.textColor = Colors.Player.trackInfoTitleTextColor
    }
    
    private func changeSecondaryTextColor() {
        [lblTrackTime, lblTimeElapsed, lblTimeRemaining, lblSpeed].forEach({$0?.textColor = Colors.Player.trackInfoArtistAlbumTextColor})
    }
    
    private func changeSliderColors() {
        progressView.redraw()
    }
    
    private func changeSliderValueTextColor() {
        progressView.redraw()
    }
    
    // MARK: Message handling
    
    func consumeMessage(_ message: ActionMessage) {
        
        if let textSizeMessage = message as? TextSizeActionMessage, textSizeMessage.actionType == .changePlayerTextSize {
                       
           changeTextSize(textSizeMessage.textSize)
           return
    
       } else if let colorSchemeActionMsg = message as? ColorSchemeActionMessage {
            
            applyColorScheme(colorSchemeActionMsg.scheme)
            return
            
        } else if let msg = message as? ColorSchemeComponentActionMessage {
            
            switch msg.actionType {
                
            case .changeBackgroundColor:
                
                changeBackgroundColor(msg.color)
                
            case .changeFunctionButtonColor:
                
                changeFunctionButtonColor(msg.color)
                
            case .changePlayerTrackInfoPrimaryTextColor:
                
                changePrimaryTextColor()
                
            case .changePlayerTrackInfoSecondaryTextColor:
                
                changeSecondaryTextColor()
                
            default:
                
                return
            }
            
            return
        }
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        if let track = player.transcodingTrack, notification is PlayingTrackInfoUpdatedNotification {
         
            updateTrackInfo(track)
            return
        }
    }
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        switch message.messageType {
            
        case .transcodingStarted:
            
            if let track = (message as? TranscodingStartedAsyncMessage)?.track {
                transcodingStarted(track)
            }
            
        case .transcodingProgress:
            
            if let progressMsg = message as? TranscodingProgressAsyncMessage {
                transcodingProgress(progressMsg)
            }
            
        case .transcodingCancelled:
            
            transcodingCancelled()
            
        case .transcodingFinished:
            
            transcodingFinished()
            
        default:
            
            return
        }
    }
}
