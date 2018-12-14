import Cocoa

class TranscodingPopupWindowController: NSWindowController, AsyncMessageSubscriber {
    
    @IBOutlet weak var lblCaption: NSTextField!
    
    @IBOutlet weak var lblTrackTime: NSTextField!
    @IBOutlet weak var lblPercentage: NSTextField!
    @IBOutlet weak var lblTimeElapsed: NSTextField!
    @IBOutlet weak var lblTimeRemaining: NSTextField!
    
    @IBOutlet weak var bar: NSProgressIndicator!
    
    var transcodedTrack: Track?
    
    var subscriberId: String {return self.className}
    
    private lazy var layoutManager: LayoutManagerProtocol = ObjectGraph.layoutManager
    
    override var windowNibName: String? {return "TranscodingPopup"}
    
    private var theWindow: NSWindow {
        return self.window!
    }
    
    override func windowDidLoad() {
        AsyncMessenger.subscribe([.transcodingProgress], subscriber: self, dispatchQueue: DispatchQueue.main)
    }
    
    func transcodingStarted(_ track: Track) {
        
        transcodedTrack = track
        
        if (!self.isWindowLoaded) {
            _ = self.window!
        }
        
        lblCaption.stringValue = String(format: "Transcoding track:   %@", transcodedTrack?.conciseDisplayName ?? "")
        lblTrackTime.stringValue = "0"
        lblPercentage.stringValue = "0 %"
        lblTimeElapsed.stringValue = "0:00"
        lblTimeRemaining.stringValue = "(Calculating ...)"
        
        bar.doubleValue = 0
        bar.startAnimation(self)
        
        // Offset the dialog from the main window a bit, before showing it
        let mwFrame = layoutManager.getMainWindowFrame()
        var thisFrame = theWindow.frame
        thisFrame.origin = mwFrame.origin.applying(CGAffineTransform.init(translationX: 25, y: -150))
        
        layoutManager.addChildWindow(theWindow)
        theWindow.setFrame(thisFrame, display: true)
        super.showWindow(self)
        theWindow.orderFront(self)
    }

    private func transcodingProgress(_ msg: TranscodingProgressAsyncMessage) {
        
        let time = StringUtils.formatSecondsToHMS(msg.timeTranscoded)
        let trackDuration = StringUtils.formatSecondsToHMS(msg.track.duration)
        let perc = Int(round(msg.percTranscoded))
        
        let elapsed = StringUtils.formatSecondsToHMS(msg.timeElapsed)
        let remaining = StringUtils.formatSecondsToHMS(msg.timeRemaining)
        
        lblTrackTime.stringValue = String(format: "%@ / %@", time, trackDuration)
        lblPercentage.stringValue = String(format: "%d %%", perc)
        lblTimeElapsed.stringValue = String(format: "%@", elapsed)
        lblTimeRemaining.stringValue = String(format: "%@", remaining)
        
        bar.doubleValue = msg.percTranscoded
    }

    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        if let msg = message as? TranscodingProgressAsyncMessage {
            transcodingProgress(msg)
            return
        }
    }
    
    override func close() {
        bar.stopAnimation(self)
        super.close()
    }
}
