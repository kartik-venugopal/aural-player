import Cocoa

class WaitingTrackViewController: NSViewController, AsyncMessageSubscriber, MessageSubscriber, ActionMessageSubscriber {
 
    @IBOutlet weak var artView: NSImageView!
    @IBOutlet weak var overlayBox: NSBox!
    
    @IBOutlet weak var lblTrackNameCaption: NSTextField!
    @IBOutlet weak var lblTrackName: NSTextField!
    @IBOutlet weak var lblTimeRemaining: NSTextField!
    
    @IBOutlet weak var controlsBox: NSBox!
    private let controlsView: NSView = ViewFactory.controlsView
    
    @IBOutlet weak var functionsBox: NSBox!
    private let functionsView: NSView = ViewFactory.playingTrackFunctionsView
    
    private var track: Track?
    private var timer: RepeatingTaskExecutor?
    private var endTime: Date?
    
    private let player: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
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
        
        SyncMessenger.subscribe(messageTypes: [.playingTrackInfoUpdatedNotification], subscriber: self)
        
        SyncMessenger.subscribe(actionTypes: [.changePlayerTextSize, .applyColorScheme, .changeBackgroundColor, .changePlayerTrackInfoPrimaryTextColor], subscriber: self)
    }
    
    private func endGap() {
        
        timer?.stop()
        timer = nil
        endTime = nil
        
        self.track = nil
    }
    
    private func updateCountdown() {
        
        if let endTime = self.endTime {
        
            let seconds = max(DateUtils.timeUntil(endTime), 0)
            lblTimeRemaining.stringValue = StringUtils.formatSecondsToHMS(seconds)
            
            if seconds == 0 {endGap()}
        }
    }
    
    private func gapStarted(_ track: Track, _ gapEndTime: Date) {
        
        self.track = track
        updateTrackInfo()
        
        endTime = gapEndTime
        updateCountdown()
        startTimer()
    }
    
    private func updateTrackInfo() {

        artView.image = track?.displayInfo.art?.image ?? Images.imgPlayingArt
        lblTrackName.stringValue = track?.conciseDisplayName ?? ""
    }
    
    private func startTimer() {
        
        timer = RepeatingTaskExecutor(intervalMillis: 500, task: {self.updateCountdown()}, queue: DispatchQueue.main)
        timer?.startOrResume()
    }
    
    private func changeTextSize(_ size: TextSize) {
        [lblTrackNameCaption, lblTrackName, lblTimeRemaining].forEach({$0?.font = Fonts.Player.infoBoxTitleFont})
    }
    
    private func applyColorScheme(_ scheme: ColorScheme) {
        
        changeBackgroundColor()
        changeTextColor()
    }
    
    private func changeBackgroundColor() {
        
        overlayBox.fillColor = Colors.windowBackgroundColor.clonedWithTransparency(overlayBox.fillColor.alphaComponent)
        artView.layer?.shadowColor = Colors.windowBackgroundColor.visibleShadowColor.cgColor
    }
    
    private func changeTextColor() {
        [lblTrackNameCaption, lblTrackName, lblTimeRemaining].forEach({$0?.textColor = Colors.Player.trackInfoTitleTextColor})
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
    
    // Consume synchronous notification messages
    func consumeNotification(_ notification: NotificationMessage) {
        
        if player.state == .waiting && notification is PlayingTrackInfoUpdatedNotification {
         
            updateTrackInfo()
            return
        }
    }
    
    func consumeMessage(_ message: ActionMessage) {
        
        if let colorComponentActionMsg = message as? ColorSchemeComponentActionMessage {
            
            if colorComponentActionMsg.actionType == .changePlayerTrackInfoPrimaryTextColor {
                
                changeTextColor()
                
            } else if colorComponentActionMsg.actionType == .changeBackgroundColor {
            
                changeBackgroundColor()
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
