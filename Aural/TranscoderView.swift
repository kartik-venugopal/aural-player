import Cocoa

class TranscoderView: NSView {
    
    @IBOutlet weak var lblTrack: NSTextField!
    
    @IBOutlet weak var lblTrackTime: NSTextField!
    @IBOutlet weak var lblTimeElapsed: NSTextField!
    @IBOutlet weak var lblTimeRemaining: NSTextField!
    @IBOutlet weak var lblSpeed: NSTextField!
    
    @IBOutlet weak var lblTranscoding: NSTextField!
    
    @IBOutlet weak var progressView: ProgressArc!
    
    @IBOutlet weak var containerBox: NSBox!
    
    func transcodingStarted(_ track: Track) {
        updateFields(track.conciseDisplayName, 0, track.duration, 0, 0, 0, "0x")
    }
    
    func transcodingProgress(_ msg: TranscodingProgressAsyncMessage) {
        updateFields(msg.track.conciseDisplayName, msg.timeTranscoded, msg.track.duration, msg.timeElapsed, msg.timeRemaining, msg.percTranscoded, msg.speed)
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
    
    func transcodingFinished() {
    }
    
    func changeBackgroundColor(_ color: NSColor) {
        
        containerBox.fillColor = color
        containerBox.isTransparent = !color.isOpaque
    }
    
    func changePrimaryTextColor() {
        lblTrack.textColor = Colors.Player.trackInfoTitleTextColor
    }
    
    func changeSecondaryTextColor() {
        [lblTrackTime, lblTimeElapsed, lblTimeRemaining, lblSpeed].forEach({$0?.textColor = Colors.Player.trackInfoArtistAlbumTextColor})
    }
    
    func changeTertiaryTextColor() {
        lblTranscoding.textColor = Colors.Player.trackInfoChapterTextColor
    }
    
    func changeSliderColors() {
        progressView.redraw()
    }
    
    func changeSliderValueTextColor() {
        progressView.redraw()
    }
}
