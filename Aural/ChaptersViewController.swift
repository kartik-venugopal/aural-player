import Cocoa

class ChaptersViewController: NSViewController, MessageSubscriber, ActionMessageSubscriber {
    
    @IBOutlet weak var chaptersView: NSTableView!
    
    @IBOutlet weak var lblSummary: NSTextField!
    
    @IBOutlet weak var btnLoopChapter: NSButton!
    
    private let player: PlaybackDelegateProtocol = ObjectGraph.playbackDelegate
    
    private var looping: Bool = false
    
    override func viewDidLoad() {
        
        PlaylistViewState.chaptersView = self.chaptersView
        initSubscriptions()
        
        looping = false
        btnLoopChapter.image = Images.imgLoopChapterOff
    }
    
    override func viewDidAppear() {
        
        chaptersView.reloadData()
        lblSummary.stringValue = String(format: "%d chapters", player.chapterCount)
    }
    
    private func initSubscriptions() {
        
        // Register self as a subscriber to synchronous message notifications
        SyncMessenger.subscribe(messageTypes: [.trackChangedNotification, .chapterChangedNotification, .playbackLoopChangedNotification], subscriber: self)
        
        SyncMessenger.subscribe(actionTypes: [.playSelectedChapter, .previousChapter, .nextChapter, .replayChapter, .toggleChapterLoop], subscriber: self)
        
        // TODO: Subscribe to "Jump to time" ActionMessage so that chapter marking is updated even if player is paused
    }
    
    @IBAction func playSelectedChapterAction(_ sender: AnyObject) {
        
        _ = SyncMessenger.publishRequest(ChapterPlaybackRequest(.playSelectedChapter, chaptersView.selectedRow))
        
        if player.playbackLoop == nil {
            looping = false
            btnLoopChapter.image = Images.imgLoopChapterOff
        }
    }
    
    @IBAction func playPreviousChapterAction(_ sender: AnyObject) {
        
        _ = SyncMessenger.publishRequest(ChapterPlaybackRequest(.previousChapter))
        
        if player.playbackLoop == nil {
            looping = false
            btnLoopChapter.image = Images.imgLoopChapterOff
        }
    }
    
    @IBAction func playNextChapterAction(_ sender: AnyObject) {
        
        _ = SyncMessenger.publishRequest(ChapterPlaybackRequest(.nextChapter))
        
        if player.playbackLoop == nil {
            looping = false
            btnLoopChapter.image = Images.imgLoopChapterOff
        }
    }
    
    @IBAction func replayChapterAction(_ sender: AnyObject) {
        
        _ = SyncMessenger.publishRequest(ChapterPlaybackRequest(.replayChapter))
        
        if player.playbackLoop == nil {
            looping = false
            btnLoopChapter.image = Images.imgLoopChapterOff
        }
    }
    
    @IBAction func loopCurrentChapterAction(_ sender: AnyObject) {
        
        if looping {
            
            // Remove the loop
            _ = SyncMessenger.publishRequest(ChapterPlaybackRequest(.removeChapterLoop))
            btnLoopChapter.image = Images.imgLoopChapterOff
            
        } else {
            
            // Start a loop
            _ = SyncMessenger.publishRequest(ChapterPlaybackRequest(.addChapterLoop))
            btnLoopChapter.image = Images.imgLoopChapterOn
        }
        
        looping = !looping
    }
    
    // MARK: Message handling
    
    var subscriberId: String {
        return self.className
    }
    
    func consumeNotification(_ message: NotificationMessage) {
        
        switch message.messageType {
            
        case .trackChangedNotification:
            
            trackChanged(message as! TrackChangedNotification)
            
        case .chapterChangedNotification:
            
            let msg = message as! ChapterChangedNotification
            chapterChanged(msg.oldChapter, msg.newChapter)
            
        case .playbackLoopChangedNotification:
            
            loopChanged()
            
        default: return
            
        }
    }
    
    func processRequest(_ request: RequestMessage) -> ResponseMessage {
        return EmptyResponse.instance
    }
    
    func consumeMessage(_ message: ActionMessage) {
        
        switch message.actionType {
            
        case .playSelectedChapter:
            
            playSelectedChapterAction(self)
            
        case .previousChapter:
            
            playPreviousChapterAction(self)
            
        case .nextChapter:
            
            playNextChapterAction(self)
            
        case .replayChapter:
            
            replayChapterAction(self)
            
        case .toggleChapterLoop:
            
            loopCurrentChapterAction(self)
            
        default: return
            
        }
    }
    
    private func trackChanged(_ msg: TrackChangedNotification) {
        
        chaptersView.reloadData()
        lblSummary.stringValue = String(format: "%d chapters", player.chapterCount)
    }
    
    private func chapterChanged(_ oldChapter: Int?, _ newChapter: Int?) {
        
        var refreshRows: [Int] = []
        
        if let _oldChapter = oldChapter, _oldChapter >= 0 {
            refreshRows.append(_oldChapter)
        }
        
        if let _newChapter = newChapter, _newChapter >= 0 {
            refreshRows.append(_newChapter)
        }
        
        if (!refreshRows.isEmpty) {
            self.chaptersView.reloadData(forRowIndexes: IndexSet(refreshRows), columnIndexes: [0])
        }
    }
    
    private func loopChanged() {
        looping = false
        btnLoopChapter.image = Images.imgLoopChapterOff
    }
}
