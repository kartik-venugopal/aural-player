import Cocoa

class ChaptersViewController: NSViewController, MessageSubscriber, ActionMessageSubscriber {
    
    @IBOutlet weak var chaptersView: NSTableView!
    
    @IBOutlet weak var lblWindowTitle: NSTextField!
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

        // Need to do this every time the view reappears (i.e. the Chapters list window is opened)
        chaptersView.reloadData()
        
        let chapterCount: Int = player.chapterCount
        lblSummary.stringValue = String(format: "%d %@", chapterCount, chapterCount == 1 ? "chapter" : "chapters")
        
        lblWindowTitle.font = TextSizes.playlistSummaryFont
        lblSummary.font = TextSizes.playlistSummaryFont
    }
    
    private func initSubscriptions() {
        
        // Register self as a subscriber to synchronous message notifications
        SyncMessenger.subscribe(messageTypes: [.trackChangedNotification, .chapterChangedNotification, .playbackLoopChangedNotification], subscriber: self)
        
        SyncMessenger.subscribe(actionTypes: [.playSelectedChapter, .previousChapter, .nextChapter, .replayChapter, .toggleChapterLoop, .changePlaylistTextSize], subscriber: self)
        
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
        
        // Should not do anything when no chapter is playing
        // (possible if chapters don't cover the entire timespan of the track)
        if player.playingChapter == nil {
            return
        }
        
        _ = SyncMessenger.publishRequest(ChapterPlaybackRequest(.replayChapter))
        
        if player.playbackLoop == nil {
            looping = false
            btnLoopChapter.image = Images.imgLoopChapterOff
        }
    }
    
    @IBAction func loopCurrentChapterAction(_ sender: AnyObject) {
        
        // Should not do anything when no chapter is playing
        // (possible if chapters don't cover the entire timespan of the track)
        if player.playingChapter == nil {
            return
        }
        
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
            
        case .changePlaylistTextSize:
            
            changeTextSize()
            
        default: return
            
        }
    }
    
    private func trackChanged(_ msg: TrackChangedNotification) {
        
        // Don't need to do this if the window is not visible
        if let _window = view.window, _window.isVisible {
            
            chaptersView.reloadData()
            
            let chapterCount: Int = player.chapterCount
            lblSummary.stringValue = String(format: "%d %@", chapterCount, chapterCount == 1 ? "chapter" : "chapters")
        }
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
    
    private func changeTextSize() {
        
        // Don't need to do this if the window is not visible
        if let _window = view.window, _window.isVisible {
        
            let selRows = chaptersView.selectedRowIndexes
            chaptersView.reloadData()
            chaptersView.selectRowIndexes(selRows, byExtendingSelection: false)
            
            lblWindowTitle.font = TextSizes.playlistSummaryFont
            lblSummary.font = TextSizes.playlistSummaryFont
        }
    }
}
