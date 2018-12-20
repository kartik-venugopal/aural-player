import Cocoa

class TranscoderView: NSView {
    
    @IBOutlet weak var lblTrack: NSTextField!
    
    @IBOutlet weak var lblTrackTime: NSTextField!
    @IBOutlet weak var lblTime: NSTextField!
    @IBOutlet weak var lblSpeed: NSTextField!
    
    @IBOutlet weak var bar: NSProgressIndicator!
    
    func transcodingStarted(_ track: Track) {
        
        lblTrack.stringValue = track.conciseDisplayName
        lblTrackTime.stringValue = "0:00  [ 0 % ]"
        lblTime.stringValue = "0:00"
        lblSpeed.stringValue = "0x"
        
        bar.doubleValue = 0
        bar.startAnimation(self)
    }
    
    func transcodingProgress(_ msg: TranscodingProgressAsyncMessage) {
        
        let trackTime = StringUtils.formatSecondsToHMS(msg.timeTranscoded)
        let trackDuration = StringUtils.formatSecondsToHMS(msg.track.duration)
        let perc = Int(round(msg.percTranscoded))
        
        let elapsed = StringUtils.formatSecondsToHMS(msg.timeElapsed)
        let remaining = StringUtils.formatSecondsToHMS(msg.timeRemaining)
        
        lblTrackTime.stringValue = String(format: "%@ / %@  [ %d %% ]", trackTime, trackDuration, perc)
        lblTime.stringValue = String(format: "%@  |  %@", elapsed, remaining)
        lblSpeed.stringValue = msg.speed
        
        bar.doubleValue = msg.percTranscoded
    }
    
    func transcodingFinished() {
        bar.stopAnimation(self)
    }
}
