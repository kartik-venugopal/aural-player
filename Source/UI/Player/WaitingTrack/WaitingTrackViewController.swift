import Cocoa

/*
    View controller for the subview within the player view that displays info about a track that is currently
    waiting to play, e.g. when a user requests delayed playback.
 
    Displays a countdown with the remaining wait time: e.g. "Track will play in: 00:00:15"

    Also handles such requests from app menus.
*/
class WaitingTrackViewController: NSViewController, NotificationSubscriber {
 
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
    
    private func initSubscriptions() {
        
        // Only respond if the waiting track was updated
        Messenger.subscribeAsync(self, .trackInfoUpdated, self.waitingTrackInfoUpdated(_:),
                                 filter: {msg in msg.updatedTrack == self.player.waitingTrack &&
                                    msg.updatedFields.contains(.art) || msg.updatedFields.contains(.displayInfo)},
                                 queue: .main)
        
        
        Messenger.subscribeAsync(self, .trackTransition, self.trackTransitioned(_:),
                                 filter: {msg in msg.gapStarted},
                                 queue: .main)
        
        Messenger.subscribe(self, .changePlayerTextSize, self.changeTextSize(_:))
        
        Messenger.subscribe(self, .colorScheme_applyColorScheme, self.applyColorScheme(_:))
        Messenger.subscribe(self, .colorScheme_changeBackgroundColor, self.changeBackgroundColor(_:))
        Messenger.subscribe(self, .colorScheme_changePlayerTrackInfoPrimaryTextColor, self.changeTextColor(_:))
    }
    
    override func viewDidAppear() {
        
        DispatchQueue.main.async {
            
            if !self.controlsView.isDescendant(of: self.controlsBox) {
                
                self.controlsView.removeFromSuperview()
                self.controlsBox.addSubview(self.controlsView)
            }

            if !self.functionsView.isDescendant(of: self.functionsBox) {
                
                self.functionsView.removeFromSuperview()
                self.functionsBox.addSubview(self.functionsView)
            }

            self.functionsBox.showIf(PlayerViewState.showPlayingTrackFunctions)
        }
    }
    
    private func endGap() {
        
        timer?.stop()
        timer = nil
        endTime = nil
        
        track = nil
    }
    
    // Updates the countdown info fields with the remaining wait time.
    private func updateCountdown() {
        
        if let endTime = self.endTime {
        
            let seconds = max(DateUtils.timeUntil(endTime), 0)
            lblTimeRemaining.stringValue = ValueFormatter.formatSecondsToHMS(seconds)
            
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
    
    func waitingTrackInfoUpdated(_ notification: TrackInfoUpdatedNotification) {
        updateTrackInfo()
    }
    
    func updateTrackInfo() {

        artView.image = track?.displayInfo.art?.image ?? Images.imgPlayingArt
        lblTrackName.stringValue = track?.conciseDisplayName ?? ""
    }
    
    private func startTimer() {
        
        timer = RepeatingTaskExecutor(intervalMillis: 500, task: {self.updateCountdown()}, queue: .main)
        timer?.startOrResume()
    }
    
    private func changeTextSize(_ size: TextSize) {
        [lblTrackNameCaption, lblTrackName, lblTimeRemaining].forEach({$0?.font = Fonts.Player.infoBoxTitleFont})
    }
    
    private func applyColorScheme(_ scheme: ColorScheme) {
        
        changeBackgroundColor(scheme.general.backgroundColor)
        changeTextColor(scheme.player.trackInfoPrimaryTextColor)
    }
    
    private func changeBackgroundColor(_ color: NSColor) {
        
        overlayBox.fillColor = Colors.windowBackgroundColor.clonedWithTransparency(overlayBox.fillColor.alphaComponent)
        artView.layer?.shadowColor = Colors.windowBackgroundColor.visibleShadowColor.cgColor
    }
    
    private func changeTextColor(_ color: NSColor) {
        [lblTrackNameCaption, lblTrackName, lblTimeRemaining].forEach({$0?.textColor = Colors.Player.trackInfoTitleTextColor})
    }
    
    // MARK: Message handling

    func trackTransitioned(_ notification: TrackTransitionNotification) {
        
        if let track = notification.endTrack, let endTime = notification.gapEndTime {
            gapStarted(track, endTime)
        }
    }
}
