import Cocoa

class GapView: NSView {
    
    @IBOutlet weak var lblGapTrackName: NSTextField!
    @IBOutlet weak var lblGapTimeRemaining: NSTextField!
    
    private var gapTimer: RepeatingTaskExecutor?
    
    func clearNowPlayingInfo() {
        
        // If gap is ongoing, end it
            gapTimer?.stop()
            gapTimer = nil
    }
    
    private func updateGapCountdown(_ endTime: Date) {
        
        let seconds = max(DateUtils.timeUntil(endTime), 0)
        lblGapTimeRemaining.stringValue = StringUtils.formatSecondsToHMS(seconds)
        
        if seconds == 0 {
            gapTimer?.stop()
            gapTimer = nil
        }
    }
    
    func gapStarted(_ msg: PlaybackGapStartedAsyncMessage) {
        
        let track = msg.nextTrack.track
        
        lblGapTrackName.stringValue = String(format: "Up next:   %@", track.conciseDisplayName)
        updateGapCountdown(msg.gapEndTime)
        
        gapTimer = RepeatingTaskExecutor(intervalMillis: 500, task: {
            
            self.updateGapCountdown(msg.gapEndTime)
            
        }, queue: DispatchQueue.main)
        
        gapTimer?.startOrResume()
    }
}
