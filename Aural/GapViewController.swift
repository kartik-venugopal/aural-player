/*
    View controller for the Now Playing info box which displays information about the currently playing track
 */

import Cocoa

class GapViewController: NSViewController, AsyncMessageSubscriber {
    
    @IBOutlet weak var artView: NSImageView!
    @IBOutlet weak var lblTrackTitle: NSTextField!
    @IBOutlet weak var lblTimeRemaining: NSTextField!
    
    private var gapTimer: RepeatingTaskExecutor?
    
    override func viewDidLoad() {
        initSubscriptions()
    }
    
    private func initSubscriptions() {
        
        // Subscribe to various notifications
        AsyncMessenger.subscribe([.gapStarted], subscriber: self, dispatchQueue: DispatchQueue.main)
    }
    
    private func removeSubscriptions() {
        AsyncMessenger.unsubscribe([.gapStarted], subscriber: self)
    }
    
    private func updateGapCountdown(_ endTime: Date) {
        lblTimeRemaining.stringValue = StringUtils.formatSecondsToHMS(max(DateUtils.timeUntil(endTime), 0))
    }
    
    private func gapStarted(_ msg: PlaybackGapStartedAsyncMessage) {
        
        let track = msg.nextTrack.track
        
        lblTrackTitle.stringValue = String(format: "Up next:   %@", track.conciseDisplayName)
        updateGapCountdown(msg.gapEndTime)
        
        artView.isHidden = !NowPlayingViewState.DefaultViewState.showAlbumArt
        
        if (track.displayInfo.art != nil) {
            
            artView.image = track.displayInfo.art!
            
        } else {
            
            // Default artwork
            artView.image = Images.imgPausedArt
        }
        
        gapTimer = RepeatingTaskExecutor(intervalMillis: 500, task: {
            
            self.updateGapCountdown(msg.gapEndTime)
            
        }, queue: DispatchQueue.main)
        
        gapTimer?.startOrResume()
    }
    
    // MARK: Message handling
    
    func getID() -> String {
        return self.className
    }
    
    // Consume asynchronous messages
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        switch message.messageType {
            
        case .gapStarted:
            
            gapStarted(message as! PlaybackGapStartedAsyncMessage)
            
        default: return
            
        }
    }
}
