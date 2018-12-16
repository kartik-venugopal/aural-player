import Cocoa

class TranscoderViewController: NSViewController, AsyncMessageSubscriber {
    
    @IBOutlet weak var theView: TranscoderView!
    
    private lazy var player: PlaybackDelegateProtocol = ObjectGraph.playbackDelegate
    
    var subscriberId: String {return self.className}
    
    override func viewDidLoad() {
        AsyncMessenger.subscribe([.transcodingStarted, .transcodingProgress, .transcodingFinished], subscriber: self, dispatchQueue: DispatchQueue.main)
    }
    
    func transcodingStarted(_ track: Track) {
        
        theView.transcodingStarted(track)
        bringViewToFront(theView)
        theView.show()
    }
    
    fileprivate func bringViewToFront(_ aView: NSView) {
        
        let superView = aView.superview
        aView.removeFromSuperview()
        superView?.addSubview(aView, positioned: .above, relativeTo: nil)
    }

    private func transcodingProgress(_ msg: TranscodingProgressAsyncMessage) {
        theView.transcodingProgress(msg)
    }
    
    private func transcodingFinished() {
        
        theView.transcodingFinished()
        theView.hide()
    }
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        switch message.messageType {
            
        case .transcodingStarted:
            
            transcodingStarted((message as! TranscodingStartedAsyncMessage).track)
            
        case .transcodingProgress:
            
            transcodingProgress(message as! TranscodingProgressAsyncMessage)
            
        case .transcodingFinished:
            
            transcodingFinished()
            
        default: return
            
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        
        player.cancelTranscoding()
        theView.transcodingFinished()
        theView.hide()
    }
}
