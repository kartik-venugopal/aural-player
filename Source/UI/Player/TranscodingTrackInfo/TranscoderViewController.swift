import Cocoa

class TranscoderViewController: NSViewController, AsyncMessageSubscriber, ActionMessageSubscriber {
    
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
        
        SyncMessenger.subscribe(actionTypes: [.changePlayerView, .showOrHideAlbumArt, .showOrHideArtist, .showOrHideAlbum, .showOrHideCurrentChapter, .showOrHideMainControls, .showOrHidePlayingTrackInfo, .showOrHideSequenceInfo, .showOrHidePlayingTrackFunctions, .changePlayerTextSize, .applyColorScheme, .changeBackgroundColor, .changePlayerTrackInfoPrimaryTextColor, .changePlayerTrackInfoSecondaryTextColor, .changePlayerTrackInfoTertiaryTextColor], subscriber: self)
        
        AsyncMessenger.subscribe([.transcodingStarted, .transcodingProgress, .transcodingCancelled, .transcodingFinished], subscriber: self, dispatchQueue: DispatchQueue.main)
    }
    
    private func transcodingStarted(_ track: Track) {
        updateFields(track.conciseDisplayName, 0, track.duration, 0, 0, 0, "0x")
    }
    
    private func transcodingProgress(_ msg: TranscodingProgressAsyncMessage) {
        
        updateFields(msg.track.conciseDisplayName, msg.timeTranscoded, msg.track.duration,
                     msg.timeElapsed, msg.timeRemaining, msg.percTranscoded, msg.speed)
    }
    
    private func transcodingFinished() {
        // TODO - Do we even need this method ???
    }
    
    private func transcodingCancelled() {
        transcodingFinished()
    }
    
    private func updateFields(_ trackName: String, _ timeTranscoded: Double, _ trackDuration: Double, _ timeElapsed: Double, _ timeRemaining: Double, _ percentage: Double, _ speed: String) {
        
        lblTrack.stringValue = trackName
        
        let trackTime = StringUtils.formatSecondsToHMS(timeTranscoded)
        let trackDuration = StringUtils.formatSecondsToHMS(trackDuration)
        
        let elapsed = StringUtils.formatSecondsToHMS(timeElapsed)
        let remaining = StringUtils.formatSecondsToHMS(timeRemaining)
        
        lblTrackTime.stringValue = String(format: "Track time:   %@  /  %@", trackTime, trackDuration)
        lblTimeElapsed.stringValue = String(format: "Time elapsed:   %@", elapsed)
        lblTimeRemaining.stringValue = String(format: "Time remaining:   %@", remaining)
        lblSpeed.stringValue = String(format: "Speed:   %@", speed)
        
        progressView.percentage = percentage
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        
        player.cancelTranscoding()
        transcodingFinished()
    }

    // MARK: Appearance
    
    private func changeTextSize(_ size: TextSize) {
        // TODO
    }
    
    private func applyColorScheme(_ scheme: ColorScheme) {
        
        changeBackgroundColor(scheme.general.backgroundColor)
        changeFunctionButtonColor(scheme.general.functionButtonColor)
        changeTextButtonColor()
        
        changePrimaryTextColor()
        changeSecondaryTextColor()
        changeTertiaryTextColor()
        
        changeSliderColors()
        changeSliderValueTextColor()
    }
    
    private func changeBackgroundColor(_ color: NSColor) {
        
        containerBox.fillColor = color
        containerBox.isTransparent = !color.isOpaque
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
    }
    
    private func changeSecondaryTextColor() {
        [lblTrackTime, lblTimeElapsed, lblTimeRemaining, lblSpeed].forEach({$0?.textColor = Colors.Player.trackInfoArtistAlbumTextColor})
    }
    
    private func changeTertiaryTextColor() {
        lblTranscoding.textColor = Colors.Player.trackInfoChapterTextColor
    }
    
    private func changeSliderColors() {
        progressView.redraw()
    }
    
    private func changeSliderValueTextColor() {
        progressView.redraw()
    }
    
    // MARK: Message handling
    
    var subscriberId: String {return self.className}
    
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
                
            case .changePlayerTrackInfoPrimaryTextColor:
                
                changePrimaryTextColor()
                
            case .changePlayerTrackInfoSecondaryTextColor:
                
                changeSecondaryTextColor()
                
            case .changePlayerTrackInfoTertiaryTextColor:
                
                changeTertiaryTextColor()
                
            default:
                
                return
            }
            
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
