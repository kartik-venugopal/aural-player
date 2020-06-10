import Cocoa

/*
    View controller for the subview within the player view that displays info about a track that is currently
    being transcoded, e.g. an Ogg Vorbis file.
 
    Displays transcoding progress, e.g. percentage transcoded, speed, and estimated time remaining.
*/
class TranscoderViewController: NSViewController, AsyncMessageSubscriber, MessageSubscriber, ActionMessageSubscriber {
    
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
        
        changeTextSize(PlayerViewState.textSize)
        applyColorScheme(ColorSchemes.systemScheme)
        
        initSubscriptions()
    }
    
    override func viewDidAppear() {
        
        if !controlsView.isDescendant(of: controlsBox) {
            
            controlsView.removeFromSuperview()
            controlsBox.addSubview(controlsView)
        }
        
        if !functionsView.isDescendant(of: functionsBox) {
            
            functionsView.removeFromSuperview()
            functionsBox.addSubview(functionsView)
        }
        
        functionsBox.showIf(PlayerViewState.showPlayingTrackFunctions)
    }
    
    private func initSubscriptions() {
        
        SyncMessenger.subscribe(messageTypes: [.trackTransitionNotification, .playingTrackInfoUpdatedNotification], subscriber: self)
        
        SyncMessenger.subscribe(actionTypes: [.changePlayerTextSize, .applyColorScheme, .changeBackgroundColor, .changeFunctionButtonColor, .changePlayerTrackInfoPrimaryTextColor, .changePlayerTrackInfoSecondaryTextColor, .changePlayerSliderColors], subscriber: self)
        
        AsyncMessenger.subscribe([.transcodingProgress], subscriber: self, dispatchQueue: DispatchQueue.main)
    }
    
    private func transcodingStarted(_ track: Track) {
        
        lblTrack.stringValue = track.conciseDisplayName
        artView.image = track.displayInfo.art?.image ?? Images.imgPlayingArt
        
        updateFields(0, 0, 0)
    }
    
    private func transcodingProgress(_ msg: TranscodingProgressAsyncMessage) {
        updateFields(msg.timeElapsed, msg.timeRemaining, msg.percTranscoded)
    }
    
    private func updateFields(_ timeElapsed: Double, _ timeRemaining: Double, _ percentage: Double) {
        
        let elapsed = ValueFormatter.formatSecondsToHMS(timeElapsed)
        let remaining = ValueFormatter.formatSecondsToHMS(timeRemaining)
        
        lblTimeElapsed.stringValue = String(format: "Time elapsed:   %@", elapsed)
        lblTimeRemaining.stringValue = String(format: "Time remaining:   %@", remaining)
        
        progressView.percentage = percentage
    }
    
    private func updateTrackInfo(_ track: Track) {

        lblTrack.stringValue = track.conciseDisplayName
        artView.image = track.displayInfo.art?.image ?? Images.imgPlayingArt
    }

    // MARK: Appearance
    
    private func changeTextSize(_ size: TextSize) {
        
        lblTrack.font = Fonts.Player.infoBoxTitleFont
        [lblTimeElapsed, lblTimeRemaining].forEach({$0?.font = Fonts.Player.trackTimesFont})
    }
    
    private func applyColorScheme(_ scheme: ColorScheme) {
        
        changeBackgroundColor(scheme.general.backgroundColor)
        changeFunctionButtonColor(scheme.general.functionButtonColor)
        
        changePrimaryTextColor()
        changeSecondaryTextColor()
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
    
    private func changePrimaryTextColor() {
        lblTrack.textColor = Colors.Player.trackInfoTitleTextColor
    }
    
    private func changeSecondaryTextColor() {
        
        [lblTimeElapsed, lblTimeRemaining].forEach({
            $0?.textColor = Colors.Player.trackInfoArtistAlbumTextColor
        })
        
        progressView.redraw()
    }
    
    private func changeSliderColors() {
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
                
            case .changePlayerSliderColors:
                
                changeSliderColors()
                
            default:
                
                return
            }
            
            return
        }
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        if let trackTransitionMsg = notification as? TrackTransitionNotification, trackTransitionMsg.transcodingStarted,
            let track = trackTransitionMsg.endTrack {
            
            transcodingStarted(track)
            return
            
        } else if let track = player.transcodingTrack, notification is PlayingTrackInfoUpdatedNotification {
         
            updateTrackInfo(track)
            return
        }
    }
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        switch message.messageType {
            
        case .transcodingProgress:
            
            if let progressMsg = message as? TranscodingProgressAsyncMessage {
                transcodingProgress(progressMsg)
            }
            
        default:
            
            return
        }
    }
}
