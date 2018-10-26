/*
    View controller for the Now Playing info box which displays information about the currently playing track
 */

import Cocoa

class GapViewController: NSViewController {
    
    @IBOutlet weak var defaultView: PlayerView!
    @IBOutlet weak var expandedArtView: PlayerView!
    
    private var theView: PlayerView? {
        return PlayerViewState.viewType == .defaultView ? defaultView : expandedArtView
    }
//    
//    override func viewDidLoad() {
//        initSubscriptions()
//    }
//    
//    private func initSubscriptions() {
//        
//        // Subscribe to various notifications
//        AsyncMessenger.subscribe([.gapStarted], subscriber: self, dispatchQueue: DispatchQueue.main)
//    }
//    
//    private func removeSubscriptions() {
//        AsyncMessenger.unsubscribe([.gapStarted], subscriber: self)
//    }
    
    
    
    // MARK: Message handling
    
    func getID() -> String {
        return self.className
    }
    
    
}
