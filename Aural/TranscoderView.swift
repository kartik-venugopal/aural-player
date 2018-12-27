import Cocoa

class TranscoderView: NSView {
    
    @IBOutlet weak var lblTrack: NSTextField!
//    @IBOutlet weak var lblPercentage: NSTextField!
    
    @IBOutlet weak var lblTrackTime: NSTextField!
    @IBOutlet weak var lblTimeElapsed: NSTextField!
    @IBOutlet weak var lblTimeRemaining: NSTextField!
    @IBOutlet weak var lblSpeed: NSTextField!
    
    @IBOutlet weak var bar: NSProgressIndicator!
    
    @IBOutlet weak var arc: ProgressArc!
    
    func transcodingStarted(_ track: Track) {
        
        lblTrack.stringValue = track.conciseDisplayName
        
        lblTrackTime.stringValue = "Track time:   0:00  /  0:00"
        lblTimeElapsed.stringValue = "Time elapsed:   0:00"
        lblTimeRemaining.stringValue = "Time remaining:   0:00"
        lblSpeed.stringValue = "Speed:   0x"
        
        bar.doubleValue = 0
        arc.perc = 0
        bar.startAnimation(self)
    }
    
    func transcodingProgress(_ msg: TranscodingProgressAsyncMessage) {
        
        let trackTime = StringUtils.formatSecondsToHMS(msg.timeTranscoded)
        let trackDuration = StringUtils.formatSecondsToHMS(msg.track.duration)
        
        let elapsed = StringUtils.formatSecondsToHMS(msg.timeElapsed)
        let remaining = StringUtils.formatSecondsToHMS(msg.timeRemaining)
        
        lblTrackTime.stringValue = String(format: "Track time:   %@  /  %@", trackTime, trackDuration)
        lblTimeElapsed.stringValue = String(format: "Time elapsed:   %@", elapsed)
        lblTimeRemaining.stringValue = String(format: "Time remaining:   %@", remaining)
        lblSpeed.stringValue = String(format: "Speed:   %@", msg.speed)
        
//        bar.doubleValue = msg.percTranscoded
        
        arc.perc = msg.percTranscoded
    }
    
    func transcodingFinished() {
        bar.stopAnimation(self)
    }
}
