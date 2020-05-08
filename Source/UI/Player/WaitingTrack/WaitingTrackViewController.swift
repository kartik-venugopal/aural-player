import Cocoa

class WaitingTrackViewController: NSViewController, AsyncMessageSubscriber, ActionMessageSubscriber {
 
    @IBOutlet weak var artView: NSImageView!
    
    @IBOutlet weak var lblTrackNameCaption: NSTextField!
    @IBOutlet weak var lblTrackName: NSTextField!
    @IBOutlet weak var lblTimeRemaining: NSTextField!
    
    @IBOutlet weak var controlsBox: NSBox!
    private let controlsView: NSView = ViewFactory.controlsView
    
    @IBOutlet weak var functionsBox: NSBox!
    private let functionsView: NSView = ViewFactory.playingTrackFunctionsView
    
    private var timer: RepeatingTaskExecutor?
    private var endTime: Date?
    
    override var nibName: String? {return "WaitingTrack"}
    
    override func viewDidLoad() {
        
        changeTextSize(PlayerViewState.textSize)
        applyColorScheme(ColorSchemes.systemScheme)
        
        initSubscriptions()
    }
    
    override func viewDidAppear() {
        
        controlsView.removeFromSuperview()
        controlsBox.addSubview(controlsView)
        
        functionsView.removeFromSuperview()
        functionsBox.addSubview(functionsView)
    }
    
    private func initSubscriptions() {
        
        AsyncMessenger.subscribe([.gapStarted], subscriber: self, dispatchQueue: DispatchQueue.main)
        
        SyncMessenger.subscribe(actionTypes: [.changePlayerTextSize, .changePlayerTrackInfoPrimaryTextColor, .changePlayerTrackInfoSecondaryTextColor], subscriber: self)
    }
    
    private func endGap() {
        
        timer?.stop()
        timer = nil
        endTime = nil
    }
    
    private func updateCountdown() {
        
        if let endTime = self.endTime {
        
            let seconds = max(DateUtils.timeUntil(endTime), 0)
            lblTimeRemaining.stringValue = StringUtils.formatSecondsToHMS(seconds)
            
            if seconds == 0 {endGap()}
        }
    }
    
    private func gapStarted(_ track: Track, _ gapEndTime: Date) {
        
        artView.image = track.displayInfo.art?.image ?? Images.imgPlayingArt
        
        endTime = gapEndTime
        
        lblTrackName.stringValue = track.conciseDisplayName
        updateCountdown()
        startTimer()
    }
    
    private func startTimer() {
        
        timer = RepeatingTaskExecutor(intervalMillis: 500, task: {self.updateCountdown()}, queue: DispatchQueue.main)
        timer?.startOrResume()
    }
    
    private func changeTextSize(_ size: TextSize) {
        
        lblTrackNameCaption.font = Fonts.Player.gapCaptionFont
        lblTrackName.font = Fonts.Player.infoBoxTitleFont
        lblTimeRemaining.font = Fonts.Player.gapCaptionFont
    }
    
    private func applyColorScheme(_ scheme: ColorScheme) {
        
        changePrimaryTextColor()
        changeSecondaryTextColor()
    }
    
    private func changePrimaryTextColor() {
        lblTrackName.textColor = Colors.Player.trackInfoTitleTextColor
    }
    
    private func changeSecondaryTextColor() {
        
        lblTrackNameCaption.textColor = Colors.Player.trackInfoArtistAlbumTextColor
        lblTimeRemaining.textColor = Colors.Player.trackInfoArtistAlbumTextColor
    }
    
    // MARK: Message handling
    
    var subscriberId: String {
        return self.className
    }
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        if let gapStartedMsg = message as? PlaybackGapStartedAsyncMessage {
            
            gapStarted(gapStartedMsg.nextTrack.track, gapStartedMsg.gapEndTime)
            return
        }
    }
    
    func consumeMessage(_ message: ActionMessage) {
        
        if let colorComponentActionMsg = message as? ColorSchemeComponentActionMessage {
            
            if colorComponentActionMsg.actionType == .changePlayerTrackInfoPrimaryTextColor {
                
                changePrimaryTextColor()
                
            } else if colorComponentActionMsg.actionType == .changePlayerTrackInfoSecondaryTextColor {
                
                changeSecondaryTextColor()
            }
            
            return
            
        } else if let colorSchemeActionMsg = message as? ColorSchemeActionMessage {
            
            applyColorScheme(colorSchemeActionMsg.scheme)
            return
            
        } else if let textSizeMessage = message as? TextSizeActionMessage, textSizeMessage.actionType == .changePlayerTextSize {
            
            changeTextSize(textSizeMessage.textSize)
            return
        }
    }
}
