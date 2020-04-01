import Cocoa

class ChaptersWindowController: NSWindowController, MessageSubscriber {
    
    @IBOutlet weak var chaptersView: NSTableView!
    
    @IBOutlet weak var lblSummary: NSTextField!
    
    @IBOutlet weak var btnLoopChapter: NSButton!
    
    private let player: PlaybackDelegateProtocol = ObjectGraph.playbackDelegate
    
    private var curChapter: Int? = nil
    private var looping: Bool = false
    
    override var windowNibName: String? {return "Chapters"}
    
    override func windowDidLoad() {
        
        initSubscriptions()
        
        chaptersView.reloadData()
        lblSummary.stringValue = String(format: "%d chapters", player.chapterCount)
        beginPollingForChapterChange()
    }
    
    private func initSubscriptions() {
        
        // Register self as a subscriber to synchronous message notifications
        SyncMessenger.subscribe(messageTypes: [.trackChangedNotification, .playbackLoopChangedNotification], subscriber: self)
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
        
        player.playChapter(chaptersView.selectedRow)
        
        if player.playbackLoop == nil {
            looping = false
            btnLoopChapter.image = Images.imgRepeatOff
        }
    }
    
    @IBAction func playPreviousChapterAction(_ sender: AnyObject) {
        
        player.previousChapter()
        
        if player.playbackLoop == nil {
            looping = false
            btnLoopChapter.image = Images.imgRepeatOff
        }
    }
    
    @IBAction func playNextChapterAction(_ sender: AnyObject) {
        
        player.nextChapter()
        
        if player.playbackLoop == nil {
            looping = false
            btnLoopChapter.image = Images.imgRepeatOff
        }
    }
    
    @IBAction func loopCurrentChapterAction(_ sender: AnyObject) {
        
        if looping {
            
            // Remove the loop
            _ = player.toggleLoop()
            btnLoopChapter.image = Images.imgRepeatOff
            
        } else {
            
            // Start a loop
            player.loopChapter()
            btnLoopChapter.image = Images.imgRepeatOn
        }
        
        looping = !looping
        
        SyncMessenger.publishNotification(ChapterLoopCreatedNotification.instance)
    }
    
    @IBAction func closeWindowAction(_ sender: AnyObject) {
        window!.setIsVisible(false)
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
    
    private func trackChanged(_ msg: TrackChangedNotification) {
        
        let chapterCount = player.chapterCount
        
        chaptersView.reloadData()
        lblSummary.stringValue = String(format: "%d chapters", chapterCount)
        
        if chapterCount > 0 {
            beginPollingForChapterChange()
        } else {
            stopPollingForChapterChange()
            curChapter = nil
        }
    }
    
    private func loopChanged() {
        looping = false
        btnLoopChapter.image = Images.imgRepeatOff
    }
}
