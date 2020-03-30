import Cocoa

class ChaptersWindowController: NSWindowController {
    override var windowNibName: String? {return "Chapters"}
}

class ChaptersViewController: NSViewController, MessageSubscriber {
    
    @IBOutlet weak var chaptersView: NSTableView!
    
    @IBOutlet weak var btnLoopChapter: NSButton!
    
    private let player: PlaybackDelegateProtocol = ObjectGraph.playbackDelegate
    
    override var nibName: String? {return "Chapters"}
    
    override func viewDidLoad() {
        chaptersView.reloadData()
        initSubscriptions()
    }
    
    private func initSubscriptions() {
        
        // Register self as a subscriber to synchronous message notifications
        SyncMessenger.subscribe(messageTypes: [.playbackLoopChangedNotification], subscriber: self)
    }
    
    @IBAction func playSelectedChapterAction(_ sender: AnyObject) {
        player.playChapter(chaptersView.selectedRow)
    }
    
    @IBAction func playPreviousChapterAction(_ sender: AnyObject) {
        player.previousChapter()
    }
    
    @IBAction func playNextChapterAction(_ sender: AnyObject) {
        player.nextChapter()
    }
    
    @IBAction func loopCurrentChapterAction(_ sender: AnyObject) {
        
        player.loopChapter()
        btnLoopChapter.image = Images.imgRepeatOn
        SyncMessenger.publishNotification(ChapterLoopCreatedNotification.instance)
    }
    
    // MARK: Message handling
    
    var subscriberId: String {
        return self.className
    }
    
    func consumeNotification(_ message: NotificationMessage) {
        
        switch message.messageType {
            
        case .playbackLoopChangedNotification:
            
            loopChanged()
            
        default: return
            
        }
    }
    
    func processRequest(_ request: RequestMessage) -> ResponseMessage {
        return EmptyResponse.instance
    }
    
    private func loopChanged() {
        btnLoopChapter.image = Images.imgRepeatOff
    }
}
