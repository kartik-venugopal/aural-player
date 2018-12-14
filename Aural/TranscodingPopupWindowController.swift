import Cocoa

class TranscodingPopupWindowController: NSWindowController, AsyncMessageSubscriber {
    
    @IBOutlet weak var lblProgress: NSTextField!
    @IBOutlet weak var bar: NSProgressIndicator!
    
    var subscriberId: String {return self.className}
    
    private lazy var layoutManager: LayoutManagerProtocol = ObjectGraph.layoutManager
    
    override var windowNibName: String? {return "TranscodingPopup"}
    
    private var theWindow: NSWindow {
        return self.window!
    }
    
    override func windowDidLoad() {
        AsyncMessenger.subscribe([.transcodingProgress], subscriber: self, dispatchQueue: DispatchQueue.main)
    }
    
    override func showWindow(_ sender: Any?) {
        
        if (!self.isWindowLoaded) {
            _ = self.window!
        }
        
        lblProgress.stringValue = "Track time transcoded:  0\nPercentage completed:  0 %%\nTime elapsed:   0:00\nEst. time remaining:   (Calculating ...)"
        bar.doubleValue = 0
        bar.startAnimation(self)
        
        // Offset the dialog from the main window a bit, before showing it
        let mwFrame = layoutManager.getMainWindowFrame()
        var thisFrame = theWindow.frame
        thisFrame.origin = mwFrame.origin.applying(CGAffineTransform.init(translationX: 50, y: -50))
        theWindow.setFrame(thisFrame, display: true)
        
        super.showWindow(self)
    }

    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        if let msg = message as? TranscodingProgressAsyncMessage {
            
            let time = StringUtils.formatSecondsToHMS(msg.timeTranscoded)
            let trackDur = StringUtils.formatSecondsToHMS(msg.track.duration)
            let perc = Int(round(msg.percTranscoded))
            
            let elapsed = StringUtils.formatSecondsToHMS(msg.timeElapsed)
            let remaining = StringUtils.formatSecondsToHMS(msg.timeRemaining)
            
            lblProgress.stringValue = String(format: "Track time transcoded:  %@ / %@\nPercentage completed:  %d %%\nTime elapsed:   %@\nEst. time remaining:   %@", time, trackDur, perc, elapsed, remaining)
            bar.doubleValue = msg.percTranscoded
        }
    }
    
    override func close() {
        bar.stopAnimation(self)
        super.close()
    }
}
