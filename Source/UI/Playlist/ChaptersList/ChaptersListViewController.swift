//
//  ChaptersListViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
     View controller for the Chapters list.
     Displays the chapters list in a tabular format, and provides chapter search and playback functions.
 */
class ChaptersListViewController: NSViewController, Destroyable {
    
    @IBOutlet weak var chaptersListView: NSTableView!
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var clipView: NSClipView!
    
    @IBOutlet weak var header: NSTableHeaderView!
    
    @IBOutlet weak var lblWindowTitle: NSTextField!
    @IBOutlet weak var lblSummary: NSTextField!
    
    @IBOutlet weak var btnClose: TintedImageButton!
    @IBOutlet weak var btnPreviousChapter: TintedImageButton!
    @IBOutlet weak var btnNextChapter: TintedImageButton!
    @IBOutlet weak var btnReplayChapter: TintedImageButton!
    @IBOutlet weak var btnLoopChapter: OnOffImageButton!
    
    @IBOutlet weak var txtSearch: NSSearchField!
    @IBOutlet weak var btnCaseSensitive: OnOffImageButton!
    
    @IBOutlet weak var lblNumMatches: NSTextField!
    @IBOutlet weak var btnPreviousMatch: TintedImageButton!
    @IBOutlet weak var btnNextMatch: TintedImageButton!
    
    private var functionButtons: [Tintable] = []
    
    // Holds all search results from the latest performed search
    private var searchResults: [Int] = []
    
    // Points to the current search result selected within the chapters list, and assists in search result navigation.
    // Serves as an index within the searchResults array.
    // Will be nil if no results available or no chapters available.
    private var resultIndex: Int?
    
    private let player: PlaybackDelegateProtocol = objectGraph.playbackDelegate
    
    private let fontSchemesManager: FontSchemesManager = objectGraph.fontSchemesManager
    private let colorSchemesManager: ColorSchemesManager = objectGraph.colorSchemesManager
    
    private lazy var messenger = Messenger(for: self)
    
    private lazy var uiState: PlaylistUIState = objectGraph.playlistUIState
    
    override func viewDidLoad() {
        
        scrollView.drawsBackground = false
        clipView.drawsBackground = false
        
        functionButtons = [btnClose, btnPreviousChapter, btnNextChapter, btnReplayChapter,
                           btnLoopChapter, btnCaseSensitive, btnPreviousMatch, btnNextMatch]
        
        applyColorScheme(colorSchemesManager.systemScheme)
        
        chaptersListView.customizeHeader(heightIncrease: 5, customCellType: ChaptersListTableHeaderCell.self)
        
        // Set these fields for later access
        uiState.chaptersListView = self.chaptersListView
        
        initSubscriptions()
        
        btnLoopChapter.off()
        
        lblNumMatches.stringValue = ""
        [btnPreviousMatch, btnNextMatch].forEach({$0?.disable()})
    }
    
    private func initSubscriptions() {
        
        messenger.subscribe(to: .player_chapterChanged, handler: chapterChanged(_:))
        
        messenger.subscribe(to: .player_playbackLoopChanged, handler: playbackLoopChanged)
        
        messenger.subscribeAsync(to: .player_trackTransitioned, handler: trackChanged)
        
        messenger.subscribe(to: .chaptersList_playSelectedChapter, handler: playSelectedChapter)
        
        messenger.subscribe(to: .applyTheme, handler: applyTheme)
        messenger.subscribe(to: .applyFontScheme, handler: applyFontScheme(_:))
        messenger.subscribe(to: .applyColorScheme, handler: applyColorScheme(_:))
        messenger.subscribe(to: .changeBackgroundColor, handler: changeBackgroundColor(_:))
        messenger.subscribe(to: .changeFunctionButtonColor, handler: changeFunctionButtonColor(_:))
        messenger.subscribe(to: .changeToggleButtonOffStateColor, handler: changeToggleButtonOffStateColor(_:))
        messenger.subscribe(to: .changeMainCaptionTextColor, handler: changeMainCaptionTextColor(_:))
        
        messenger.subscribe(to: .playlist_changeTrackNameTextColor, handler: changeTrackNameTextColor(_:))
        messenger.subscribe(to: .playlist_changeIndexDurationTextColor, handler: changeIndexDurationTextColor(_:))
        
        messenger.subscribe(to: .playlist_changeTrackNameSelectedTextColor, handler: changeTrackNameSelectedTextColor(_:))
        messenger.subscribe(to: .playlist_changeIndexDurationSelectedTextColor, handler: changeIndexDurationSelectedTextColor(_:))
        
        messenger.subscribe(to: .playlist_changePlayingTrackIconColor, handler: changePlayingTrackIconColor(_:))
        messenger.subscribe(to: .playlist_changeSelectionBoxColor, handler: changeSelectionBoxColor(_:))
        
        messenger.subscribe(to: .playlist_changeSummaryInfoColor, handler: changeSummaryInfoColor(_:))
    }
    
    func destroy() {
        messenger.unsubscribeFromAll()
    }
    
    override func viewDidAppear() {
        
        // Need to do this every time the view reappears (i.e. the Chapters list window is opened)
        chaptersListView.reloadData()
        
        if let chapter = player.playingChapter, chapter.index < chaptersListView.numberOfRows {
            chaptersListView.scrollRowToVisible(chapter.index)
        }
        
        let chapterCount: Int = player.chapterCount
        lblSummary.stringValue = String(format: "%d %@", chapterCount, chapterCount == 1 ? "chapter" : "chapters")
        
        lblWindowTitle.font = fontSchemesManager.systemScheme.playlist.chaptersListCaptionFont
        lblSummary.font = fontSchemesManager.systemScheme.playlist.summaryFont
        
        txtSearch.font = fontSchemesManager.systemScheme.playlist.chaptersListSearchFont
        lblNumMatches.font = fontSchemesManager.systemScheme.playlist.chaptersListSearchFont
        
        btnLoopChapter.onIf(player.chapterLoopExists)
        
        // Make sure the chapters list view has focus every time the window is opened
        self.view.window?.makeFirstResponder(chaptersListView)
    }
    
    // MARK: Playback functions
    
    @IBAction func playSelectedChapterAction(_ sender: AnyObject) {
        playSelectedChapter()
    }
    
    private func playSelectedChapter() {
        
        if let selRow = chaptersListView.selectedRowIndexes.first {
            
            messenger.publish(.player_playChapter, payload: selRow)
            btnLoopChapter.onIf(player.chapterLoopExists)
            
            // Remove focus from the search field (if necessary)
            self.view.window?.makeFirstResponder(chaptersListView)
        }
    }
    
    @IBAction func playPreviousChapterAction(_ sender: AnyObject) {
        
        messenger.publish(.player_previousChapter)
        btnLoopChapter.onIf(player.chapterLoopExists)
        
        // Remove focus from the search field (if necessary)
        self.view.window?.makeFirstResponder(chaptersListView)
    }
    
    @IBAction func playNextChapterAction(_ sender: AnyObject) {
        
        messenger.publish(.player_nextChapter)
        btnLoopChapter.onIf(player.chapterLoopExists)
        
        // Remove focus from the search field (if necessary)
        self.view.window?.makeFirstResponder(chaptersListView)
    }
    
    @IBAction func replayCurrentChapterAction(_ sender: AnyObject) {
        
        // Should not do anything when no chapter is playing
        // (possible if chapters don't cover the entire timespan of the track)
        if player.playingChapter != nil {
            
            messenger.publish(.player_replayChapter)
            btnLoopChapter.onIf(player.chapterLoopExists)
        }
        
        // Remove focus from the search field (if necessary)
        self.view.window?.makeFirstResponder(chaptersListView)
    }
    
    @IBAction func toggleCurrentChapterLoopAction(_ sender: AnyObject) {
        
        // Should not do anything when no chapter is playing
        // (possible if chapters don't cover the entire timespan of the track)
        if player.playingChapter != nil {
            
            // Toggle the loop
            messenger.publish(.player_toggleChapterLoop)
            btnLoopChapter.onIf(player.chapterLoopExists)
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
        if !queryText.isEmpty, let chapters = player.playingTrack?.chapters {
            
            searchResults = chapters.indices.filter {index in compare(queryText, chapters[index].title)}
            
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

        // Perform the search again
        btnCaseSensitive.toggle()
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
        chaptersListView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
        chaptersListView.scrollRowToVisible(row)
        
        resultIndex = index
        
        // Update the navigation buttons
        btnPreviousMatch.enableIf(index > 0)
        btnNextMatch.enableIf(index < searchResults.count - 1)
    }
    
    // Compares query text with a chapter title
    private func compare(_ queryText: String, _ chapterTitle: String) -> Bool {
        return btnCaseSensitive.isOn ? chapterTitle.contains(queryText) : chapterTitle.lowercased().contains(queryText.lowercased())
    }
    
    // Returns true if the search field has focus, false if not.
    var isPerformingSearch: Bool {
        
        // Check if the search field has focus (i.e. it's the first responder of the Chapters list window).
        
        if let firstResponderView = self.view.window?.firstResponder as? NSView {
        
            // Iterate up the view hierarchy of the first responder view to see if any of its parent views
            // is the search field.
            
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
    
    func trackChanged() {
        
        // Don't need to do this if the window is not visible
        if view.window?.isVisible ?? false {
            
            chaptersListView.reloadData()
            chaptersListView.scrollRowToVisible(0)
            
            let chapterCount: Int = player.chapterCount
            lblSummary.stringValue = String(format: "%d %@", chapterCount, chapterCount == 1 ? "chapter" : "chapters")
        }
        
        // This should always be done
        btnLoopChapter.onIf(player.chapterLoopExists)
        txtSearch.stringValue = ""
        lblNumMatches.stringValue = ""
        [btnPreviousMatch, btnNextMatch].forEach({$0?.disable()})
        resultIndex = nil
        searchResults.removeAll()
    }
    
    // When the currently playing chapter changes, the marker icon in the chapters list needs to move to the
    // new chapter.
    func chapterChanged(_ notification: ChapterChangedNotification) {
        
        // Don't need to do this if the window is not visible
        if let _window = view.window, _window.isVisible {
            
            let refreshRows: [Int] = [notification.oldChapter?.index, notification.newChapter?.index]
                .compactMap {$0}.filter({$0 >= 0})
            
            if !refreshRows.isEmpty {
                self.chaptersListView.reloadData(forRowIndexes: IndexSet(refreshRows), columnIndexes: [0])
            }
        }
        
        btnLoopChapter.onIf(player.chapterLoopExists)
    }
    
    // When the player's segment loop has been changed externally (from the player), it invalidates the chapter loop if there is one
    func playbackLoopChanged() {
        btnLoopChapter.onIf(player.chapterLoopExists)
    }
    
    private func applyTheme() {
        
        applyFontScheme(fontSchemesManager.systemScheme)
        applyColorScheme(colorSchemesManager.systemScheme)
    }
    
    private func applyFontScheme(_ fontScheme: FontScheme) {
        
        // Don't need to do this if the window is not visible
        if let _window = view.window, _window.isVisible {
            
            let selectedRows = chaptersListView.selectedRowIndexes
            chaptersListView.reloadData()
            chaptersListView.selectRowIndexes(selectedRows, byExtendingSelection: false)
            
            lblWindowTitle.font = fontSchemesManager.systemScheme.playlist.chaptersListCaptionFont
            lblSummary.font = fontSchemesManager.systemScheme.playlist.summaryFont
            
            txtSearch.font = fontSchemesManager.systemScheme.playlist.chaptersListSearchFont
            lblNumMatches.font = fontSchemesManager.systemScheme.playlist.chaptersListSearchFont
        }
    }
    
    private func applyColorScheme(_ scheme: ColorScheme) {
        
        changeBackgroundColor(scheme.general.backgroundColor)
        
        changeSummaryInfoColor(scheme.playlist.summaryInfoColor)
        changeMainCaptionTextColor(scheme.general.mainCaptionTextColor)
        
        changeFunctionButtonColor(scheme.general.functionButtonColor)
        
        redrawSearchField()
        
        chaptersListView.reloadData()
    }
    
    private func changeBackgroundColor(_ color: NSColor) {
        
        chaptersListView.backgroundColor = NSColor.clear
        header.redraw()
    }
    
    private func changeFunctionButtonColor(_ color: NSColor) {
        functionButtons.forEach {$0.reTint()}
    }
    
    private func changeToggleButtonOffStateColor(_ color: NSColor) {
        [btnLoopChapter, btnCaseSensitive].forEach {$0.reTint()}
    }
    
    private func changeSummaryInfoColor(_ color: NSColor) {
        
        [lblSummary, lblNumMatches].forEach {$0?.textColor = color}
        header.redraw()
    }
    
    private var allRows: IndexSet {
        return IndexSet(integersIn: 0..<chaptersListView.numberOfRows)
    }
    
    private func changeTrackNameTextColor(_ color: NSColor) {
        
        chaptersListView.reloadData(forRowIndexes: allRows, columnIndexes: IndexSet(integer: 1))
        redrawSearchField()
    }
    
    private func redrawSearchField() {
        
        txtSearch.textColor = Colors.Playlist.trackNameTextColor
        
        if let cell: NSSearchFieldCell = txtSearch.cell as? NSSearchFieldCell {
            
            // This is a hack to force these cells to redraw
            cell.resetCancelButtonCell()
            cell.resetSearchButtonCell()
            
            // Tint the 2 cell images according to the appropriate color.
            cell.cancelButtonCell?.image = cell.cancelButtonCell?.image?.filledWithColor(Colors.Playlist.trackNameTextColor)
            cell.searchButtonCell?.image = cell.searchButtonCell?.image?.filledWithColor(Colors.Playlist.trackNameTextColor)
        }
        
        txtSearch.redraw()
    }
    
    private func changeIndexDurationTextColor(_ color: NSColor) {
        chaptersListView.reloadData(forRowIndexes: allRows, columnIndexes: IndexSet([0, 2, 3]))
    }
    
    private func changeTrackNameSelectedTextColor(_ color: NSColor) {
        chaptersListView.reloadData(forRowIndexes: chaptersListView.selectedRowIndexes, columnIndexes: IndexSet(integer: 1))
    }
    
    private func changeIndexDurationSelectedTextColor(_ color: NSColor) {
        chaptersListView.reloadData(forRowIndexes: chaptersListView.selectedRowIndexes, columnIndexes: IndexSet([0, 2, 3]))
    }
    
    private func changeSelectionBoxColor(_ color: NSColor) {
        
        // Note down the selected rows, clear the selection, and re-select the originally selected rows (to trigger a repaint of the selection boxes)
        let selectedRows = chaptersListView.selectedRowIndexes
        
        if !selectedRows.isEmpty {
            
            chaptersListView.selectRowIndexes(IndexSet(), byExtendingSelection: false)
            chaptersListView.selectRowIndexes(selectedRows, byExtendingSelection: false)
        }
    }
    
    private func changePlayingTrackIconColor(_ color: NSColor) {
        
        if let playingChapterIndex = player.playingChapter?.index {
            chaptersListView.reloadData(forRowIndexes: IndexSet(integer: playingChapterIndex), columnIndexes: IndexSet(integer: 0))
        }
    }
    
    private func changeMainCaptionTextColor(_ color: NSColor) {
        lblWindowTitle.textColor = color
    }
}
