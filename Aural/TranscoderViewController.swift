import Cocoa

class TranscoderViewController: NSViewController, AsyncMessageSubscriber {
    
    @IBOutlet weak var theView: TranscoderView!
    @IBOutlet weak var playerView: NSView!
    
    private lazy var player: PlaybackDelegateProtocol = ObjectGraph.playbackDelegate
    
    var subscriberId: String {return self.className}
    
    override func viewDidLoad() {
        AsyncMessenger.subscribe([.transcodingStarted, .transcodingProgress, .transcodingCancelled, .transcodingFinished], subscriber: self, dispatchQueue: DispatchQueue.main)
    }
    
    func transcodingStarted(_ track: Track) {
        
        theView.transcodingStarted(track)
        bringViewToFront(theView)
        
        if player.state != .waiting {
            playerView.hide()
            theView.show()
        }
    }
    
    fileprivate func bringViewToFront(_ aView: NSView) {
        
        let superView = aView.superview
        aView.removeFromSuperview()
        superView?.addSubview(aView, positioned: .above, relativeTo: nil)
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        
        player.cancelTranscoding()
        theView.transcodingFinished()
        theView.hide()
        playerView.show()
    }

    private func transcodingProgress(_ msg: TranscodingProgressAsyncMessage) {
        
        theView.transcodingProgress(msg)
        
        if theView.isHidden && player.state == .transcoding {
            playerView.hide()
            theView.show()
        }
    }
    
    private func transcodingFinished() {

        playerView.show()
        theView.hide()
        theView.transcodingFinished()
    }
    
    private func transcodingCancelled() {
        transcodingFinished()
    }
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        switch message.messageType {
            
        case .transcodingStarted:
            
            transcodingStarted((message as! TranscodingStartedAsyncMessage).track)
            
        case .transcodingProgress:
            
            transcodingProgress(message as! TranscodingProgressAsyncMessage)
            
        case .transcodingCancelled:
            
            transcodingCancelled()
            
        case .transcodingFinished:
            
            transcodingFinished()
            
        default: return
            
        }
    }
}
