import Cocoa

class ChaptersViewController: NSViewController, MessageSubscriber, ActionMessageSubscriber {
    
    @IBOutlet weak var chaptersView: NSTableView!
    
    @IBOutlet weak var lblSummary: NSTextField!
    
    @IBOutlet weak var btnLoopChapter: NSButton!
    
    private let player: PlaybackDelegateProtocol = ObjectGraph.playbackDelegate
    
    private var curChapter: Int? = nil
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
        beginPollingForChapterChange()
    }
    
    override func viewDidDisappear() {
        stopPollingForChapterChange()
    }
    
    private func initSubscriptions() {
        
        // Register self as a subscriber to synchronous message notifications
        SyncMessenger.subscribe(messageTypes: [.trackChangedNotification, .playbackLoopChangedNotification], subscriber: self)
        
        SyncMessenger.subscribe(actionTypes: [.playSelectedChapter, .previousChapter, .nextChapter, .replayChapter, .toggleChapterLoop], subscriber: self)
        
        // TODO: Subscribe to "Jump to time" ActionMessage so that chapter marking is updated even if player is paused
    }
    
    private func beginPollingForChapterChange() {
        
        SeekTimerTaskQueue.enqueueTask("ChapterChangePollingTask", {() -> Void in
            
            let playingChapter: Int? = self.player.playingChapter
            
            if (self.curChapter != playingChapter) {
                
                var refreshRows: [Int] = []
                
                if let oldChapter = self.curChapter, oldChapter >= 0 {
                    refreshRows.append(oldChapter)
                }
                
                if let newChapter = playingChapter, newChapter >= 0 {
                    refreshRows.append(newChapter)
                }
                
                if (!refreshRows.isEmpty) {
                    self.chaptersView.reloadData(forRowIndexes: IndexSet(refreshRows), columnIndexes: [0])
                }
                
                self.curChapter = playingChapter
            }
        })
    }
    
    private func stopPollingForChapterChange() {
        SeekTimerTaskQueue.dequeueTask("ChapterChangePollingTask")
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
        
        let chapterCount = player.chapterCount
        
        chaptersView.reloadData()
        lblSummary.stringValue = String(format: "%d chapters", chapterCount)
        
        // TODO: Should not poll (if window is invisible)
        if chapterCount > 0 {
            beginPollingForChapterChange()
        } else {
            stopPollingForChapterChange()
            curChapter = nil
        }
    }
    
    private func loopChanged() {
        looping = false
        btnLoopChapter.image = Images.imgLoopChapterOff
    }
}
