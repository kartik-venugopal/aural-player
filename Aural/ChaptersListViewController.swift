import Cocoa

/*
    View controller for the Chapters list.
    Displays the chapters list in a tabular format, and provides chapter search and playback functions.
 */
class ChaptersListViewController: NSViewController, ModalComponentProtocol, MessageSubscriber, ActionMessageSubscriber {
    
    @IBOutlet weak var chaptersListView: NSTableView!
    
    @IBOutlet weak var lblWindowTitle: NSTextField!
    @IBOutlet weak var lblSummary: NSTextField!
    
    @IBOutlet weak var btnLoopChapter: NSButton!
    
    @IBOutlet weak var txtSearch: NSSearchField!
    @IBOutlet weak var btnCaseSensitive: OnOffImageButton!
    
    @IBOutlet weak var lblNumMatches: NSTextField!
    @IBOutlet weak var btnPreviousMatch: NSButton!
    @IBOutlet weak var btnNextMatch: NSButton!
    
    // Holds all search results from the latest performed search
    private var searchResults: [Int] = []
    
    // Points to the current search result selected within the chapters list, and assists in search result navigation.
    // Serves as an index within the searchResults array.
    // Will be nil if no results available or no chapters available.
    private var resultIndex: Int?
    
    private let player: PlaybackDelegateProtocol = ObjectGraph.playbackDelegate
    
    // Indicates whether or not the currently playing chapter is being looped. Will be false if there are no chapters available.
    private var looping: Bool = false {
        
        didSet {
            // Update the loop toggle button image to reflect the looping state
            btnLoopChapter.image = looping ? Images.imgLoopChapterOn : Images.imgLoopChapterOff
        }
    }
    
    override func viewDidLoad() {
        
        // Set these fields for later access
        PlaylistViewState.chaptersListView = self.chaptersListView
        
        initSubscriptions()
        
        looping = false
        
        lblNumMatches.stringValue = ""
        [btnPreviousMatch, btnNextMatch].forEach({$0?.disable()})
        
        ObjectGraph.windowManager.registerModalComponent(self)
    }
    
    // The chapters list window is only considered modal when it is the key window AND the search bar has focus
    // (i.e. a search is being performed)
    var isModal: Bool {
        return (self.view.window?.isKeyWindow ?? false) && isPerformingSearch
    }
    
    private func initSubscriptions() {
        
        // Register self as a subscriber to synchronous message notifications
        SyncMessenger.subscribe(messageTypes: [.trackChangedNotification, .chapterChangedNotification, .playbackLoopChangedNotification], subscriber: self)
        
        SyncMessenger.subscribe(actionTypes: [.playSelectedChapter, .previousChapter, .nextChapter, .replayChapter, .toggleChapterLoop, .changePlaylistTextSize], subscriber: self)
    }
    
    override func viewDidAppear() {

        // Need to do this every time the view reappears (i.e. the Chapters list window is opened)
        chaptersListView.reloadData()
        
        let chapterCount: Int = player.chapterCount
        lblSummary.stringValue = String(format: "%d %@", chapterCount, chapterCount == 1 ? "chapter" : "chapters")
        
        lblWindowTitle.font = Fonts.Playlist.summaryFont
        lblSummary.font = Fonts.Playlist.summaryFont
        
        txtSearch.font = Fonts.Playlist.chapterSearchFont
        lblNumMatches.font = Fonts.Playlist.chapterSearchFont
        
        // Make sure the chapters list view has focus every time the window is opened
        self.view.window?.makeFirstResponder(chaptersListView)
    }
    
    // MARK: Playback functions
    
    @IBAction func playSelectedChapterAction(_ sender: AnyObject) {
        
        if let selRow = chaptersListView.selectedRowIndexes.first {
        
            _ = SyncMessenger.publishRequest(ChapterPlaybackRequest(.playSelectedChapter, selRow))
            
            if player.playbackLoop == nil {
                looping = false
            }
            
            // Remove focus from the search field (if necessary)
            self.view.window?.makeFirstResponder(chaptersListView)
        }
    }
    
    @IBAction func playPreviousChapterAction(_ sender: AnyObject) {
        
        _ = SyncMessenger.publishRequest(ChapterPlaybackRequest(.previousChapter))
        
        if player.playbackLoop == nil {
            looping = false
        }
        
        // Remove focus from the search field (if necessary)
        self.view.window?.makeFirstResponder(chaptersListView)
    }
    
    @IBAction func playNextChapterAction(_ sender: AnyObject) {
        
        _ = SyncMessenger.publishRequest(ChapterPlaybackRequest(.nextChapter))
        
        if player.playbackLoop == nil {
            looping = false
        }
        
        // Remove focus from the search field (if necessary)
        self.view.window?.makeFirstResponder(chaptersListView)
    }
    
    @IBAction func replayCurrentChapterAction(_ sender: AnyObject) {
        
        // Should not do anything when no chapter is playing
        // (possible if chapters don't cover the entire timespan of the track)
        if player.playingChapter != nil {
        
            _ = SyncMessenger.publishRequest(ChapterPlaybackRequest(.replayChapter))
            
            if player.playbackLoop == nil {
                looping = false
            }
        }
        
        // Remove focus from the search field (if necessary)
        self.view.window?.makeFirstResponder(chaptersListView)
    }
    
    @IBAction func toggleCurrentChapterLoopAction(_ sender: AnyObject) {
        
        // Should not do anything when no chapter is playing
        // (possible if chapters don't cover the entire timespan of the track)
        if player.playingChapter != nil {
        
            // Toggle the loop
            _ = SyncMessenger.publishRequest(ChapterPlaybackRequest(looping ? .removeChapterLoop : .addChapterLoop))
            looping = !looping
        }
        
        // Remove focus from the search field (if necessary)
        self.view.window?.makeFirstResponder(chaptersListView)
    }
    
    // MARK: Search functions
    
    @IBAction func searchAction(_ sender: AnyObject) {
        
        let queryText = txtSearch.stringValue
        
        // Clear any previous search results
        searchResults.removeAll()
        
        // Ensure that there is some query text and that the playing track has some chapters
        if !queryText.isEmpty, let chapters = player.playingTrack?.track.chapters {

            // Compare the query text with all chapter titles
            for index in 0..<chapters.count {
                
                if compare(queryText, chapters[index].title) {
                    
                    // Append the row index for this chapter to the search results array
                    searchResults.append(index)
                }
            }
            
            let numResults: Int = searchResults.count
            let hasResults: Bool = numResults > 0
            
            // Select the first result or no row if no results
            chaptersListView.selectRowIndexes(IndexSet(hasResults ? [searchResults[0]] : []), byExtendingSelection: false)
            if hasResults {
                chaptersListView.scrollRowToVisible(searchResults[0])
            }
            
            resultIndex = hasResults ? 0 : nil
            
            // Update the search UI to indicate the number of results and allow navigation through them
            lblNumMatches.stringValue = String(format: "%d %@", numResults, numResults == 1 ? "match" : "matches")
            btnPreviousMatch.disable()
            btnNextMatch.enableIf(numResults > 1)
            
        } else {
            
            // No text or no track chapters
            lblNumMatches.stringValue = ""
            [btnPreviousMatch, btnNextMatch].forEach({$0?.disable()})
        }
    }
    
    @IBAction func toggleCaseSensitiveSearchAction(_ sender: AnyObject) {
        
        btnCaseSensitive.toggle()
        
        // Perform the search again
        searchAction(self)
    }
    
    // Navigate to the previous search result
    @IBAction func previousSearchResultAction(_ sender: AnyObject) {
        
        if let index = resultIndex, index > 0 {
            selectSearchResult(index - 1)
        }
    }
    
    // Navigate to the next search result
    @IBAction func nextSearchResultAction(_ sender: AnyObject) {
        
        if let index = resultIndex, index < searchResults.count - 1 {
            selectSearchResult(index + 1)
        }
    }
    
    /*
        Selects the given search result within the NSTableView
    
        @param index
              Index within the searchResults array (eg. first result, second result, etc)
     */
    private func selectSearchResult(_ index: Int) {
        
        // Select the search result and scroll to make it visible
        let row = searchResults[index]
        chaptersListView.selectRowIndexes(IndexSet([row]), byExtendingSelection: false)
        chaptersListView.scrollRowToVisible(row)
        
        resultIndex = index
        
        // Update the navigation buttons
        btnPreviousMatch.enableIf(resultIndex! > 0)
        btnNextMatch.enableIf(resultIndex! < searchResults.count - 1)
    }
    
    // Compares query text with a chapter title
    private func compare(_ queryText: String, _ chapterTitle: String) -> Bool {
        return btnCaseSensitive.isOn ? chapterTitle.contains(queryText) : chapterTitle.lowercased().contains(queryText.lowercased())
    }
    
    // Returns true if the search field has focus, false if not.
    private var isPerformingSearch: Bool {
        
        // Check if the search field has focus (i.e. it's the first responder of the Chapters list window)
        
        if let firstResponderView = self.view.window?.firstResponder as? NSView {
        
            // Iterate up the view hierarchy of the first responder view to see if any of its parent views
            // is the search field
            
            var curView: NSView? = firstResponderView
            while curView != nil {
                
                if curView === txtSearch {
                    return true
                }
                
                curView = curView?.superview
            }
        }
        
        return false
    }
    
    // MARK: Message handling
    
    var subscriberId: String {
        return self.className
    }
    
    func consumeNotification(_ message: NotificationMessage) {
        
        switch message.messageType {
            
        case .trackChangedNotification:
            
            trackChanged()
            
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
            
            replayCurrentChapterAction(self)
            
        case .toggleChapterLoop:
            
            toggleCurrentChapterLoopAction(self)
            
        case .changePlaylistTextSize:
            
            changeTextSize()
            
        default: return
            
        }
    }
    
    private func trackChanged() {
        
        // Don't need to do this if the window is not visible
        if let _window = view.window, _window.isVisible {
            
            chaptersListView.reloadData()
            chaptersListView.scrollRowToVisible(0)
            
            let chapterCount: Int = player.chapterCount
            lblSummary.stringValue = String(format: "%d %@", chapterCount, chapterCount == 1 ? "chapter" : "chapters")
        }
        
        // This should always be done
        looping = false
        txtSearch.stringValue = ""
        lblNumMatches.stringValue = ""
        [btnPreviousMatch, btnNextMatch].forEach({$0?.disable()})
        resultIndex = nil
        searchResults.removeAll()
    }
    
    // When the currently playing chapter changes, the marker icon in the chapters list needs to move to the
    // new chapter.
    private func chapterChanged(_ oldChapter: IndexedChapter?, _ newChapter: IndexedChapter?) {
        
        // Don't need to do this if the window is not visible
        if let _window = view.window, _window.isVisible {
        
            var refreshRows: [Int] = []
            
            if let _oldIndex = oldChapter?.index, _oldIndex >= 0 {
                refreshRows.append(_oldIndex)
            }
            
            if let _newIndex = newChapter?.index, _newIndex >= 0 {
                refreshRows.append(_newIndex)
            }
            
            if !refreshRows.isEmpty {
                self.chaptersListView.reloadData(forRowIndexes: IndexSet(refreshRows), columnIndexes: [0])
            }
        }
    }
    
    // When the player's segment loop has been changed externally (from the player), it invalidates the chapter loop if there is one
    private func loopChanged() {
        looping = false
    }
    
    private func changeTextSize() {
        
        // Don't need to do this if the window is not visible
        if let _window = view.window, _window.isVisible {
        
            let selRows = chaptersListView.selectedRowIndexes
            chaptersListView.reloadData()
            chaptersListView.selectRowIndexes(selRows, byExtendingSelection: false)
            
            lblWindowTitle.font = Fonts.Playlist.summaryFont
            lblSummary.font = Fonts.Playlist.summaryFont
            
            txtSearch.font = Fonts.Playlist.chapterSearchFont
            lblNumMatches.font = Fonts.Playlist.chapterSearchFont
        }
    }
}
