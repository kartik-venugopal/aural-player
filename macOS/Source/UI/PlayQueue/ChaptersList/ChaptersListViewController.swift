//
//  ChaptersListViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
     View controller for the Chapters list.
     Displays the chapters list in a tabular format, and provides chapter search and playback functions.
 */
class ChaptersListViewController: NSViewController {
    
    @IBOutlet weak var chaptersListView: NSTableView!
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var clipView: NSClipView!
    
    @IBOutlet weak var header: NSTableHeaderView!
    
    @IBOutlet weak var lblCaption: NSTextField!
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
    
    // Holds all search results from the latest performed search
    var searchResults: [Int] = []
    
    // Points to the current search result selected within the chapters list, and assists in search result navigation.
    // Serves as an index within the searchResults array.
    // Will be nil if no results available or no chapters available.
    var resultIndex: Int?
    
    let player: PlaybackDelegateProtocol = playbackDelegate
    
    private lazy var messenger = Messenger(for: self)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        scrollView.drawsBackground = false
        clipView.drawsBackground = false
        
        chaptersListView.customizeHeader(heightIncrease: 5, customCellType: ChaptersListTableHeaderCell.self)
        
        // Set these fields for later access
        //        uiState.chaptersListView = self.chaptersListView
        
        initSubscriptions()
        
        btnCaseSensitive?.off()
        btnLoopChapter.off()
        
        lblNumMatches?.stringValue = ""
        [btnPreviousMatch, btnNextMatch].forEach {$0?.disable()}
    }
    
    func initSubscriptions() {
        
        fontSchemesManager.registerObserver(self)
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, handler: backgroundColorChanged(_:))
        
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.buttonColor, handler: buttonColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.activeControlColor, handler: activeControlStateColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.inactiveControlColor, handler: inactiveControlStateColorChanged(_:))
        
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.captionTextColor, handler: captionTextColorChanged(_:))
        
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.primaryTextColor, handler: primaryTextColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.secondaryTextColor, handler: secondaryTextColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.tertiaryTextColor, handler: tertiaryTextColorChanged(_:))
        
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.primarySelectedTextColor, handler: primarySelectedTextColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.tertiarySelectedTextColor, handler: tertiarySelectedTextColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.textSelectionColor, handler: textSelectionColorChanged(_:))
        
        messenger.subscribe(to: .Player.chapterChanged, handler: chapterChanged(_:))
        messenger.subscribe(to: .Player.playbackLoopChanged, handler: playbackLoopChanged)
        messenger.subscribeAsync(to: .Player.trackTransitioned, handler: trackChanged)
        messenger.subscribe(to: .chaptersList_playSelectedChapter, handler: playSelectedChapter)
    }
    
    override func destroy() {
        messenger.unsubscribeFromAll()
    }
    
    override func viewWillAppear() {
        
        super.viewWillAppear()
        
        if let chapter = player.playingChapter, chapter.index < chaptersListView.numberOfRows {
            chaptersListView.scrollRowToVisible(chapter.index)
        }
        
        let chapterCount: Int = player.chapterCount
        lblSummary.stringValue = String(format: "%d %@", chapterCount, chapterCount == 1 ? "chapter" : "chapters")
        
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
            
            messenger.publish(.Player.playChapter, payload: selRow)
            btnLoopChapter.onIf(player.chapterLoopExists)
            
            // Remove focus from the search field (if necessary)
            self.view.window?.makeFirstResponder(chaptersListView)
        }
    }
    
    @IBAction func playPreviousChapterAction(_ sender: AnyObject) {
        
        messenger.publish(.Player.previousChapter)
        btnLoopChapter.onIf(player.chapterLoopExists)
        
        // Remove focus from the search field (if necessary)
        self.view.window?.makeFirstResponder(chaptersListView)
    }
    
    @IBAction func playNextChapterAction(_ sender: AnyObject) {
        
        messenger.publish(.Player.nextChapter)
        btnLoopChapter.onIf(player.chapterLoopExists)
        
        // Remove focus from the search field (if necessary)
        self.view.window?.makeFirstResponder(chaptersListView)
    }
    
    @IBAction func replayCurrentChapterAction(_ sender: AnyObject) {
        
        // Should not do anything when no chapter is playing
        // (possible if chapters don't cover the entire timespan of the track)
        if player.playingChapter != nil {
            
            messenger.publish(.Player.replayChapter)
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
            messenger.publish(.Player.toggleChapterLoop)
            btnLoopChapter.onIf(player.chapterLoopExists)
        }
        
        // Remove focus from the search field (if necessary)
        self.view.window?.makeFirstResponder(chaptersListView)
    }
    
    // MARK: Message handling
    
    var shouldRespondToTrackChange: Bool {
        view.window?.isVisible ?? false
    }
    
    func trackChanged() {
        
        // Don't need to do this if the window is not visible
        if shouldRespondToTrackChange {
            
            chaptersListView.reloadData()
            chaptersListView.scrollRowToVisible(0)
            
            let chapterCount: Int = player.chapterCount
            lblSummary.stringValue = String(format: "%d %@", chapterCount, chapterCount == 1 ? "chapter" : "chapters")
        }
        
        // This should always be done
        btnLoopChapter.onIf(player.chapterLoopExists)
        txtSearch?.stringValue = ""
        lblNumMatches?.stringValue = ""
        [btnPreviousMatch, btnNextMatch].forEach {$0?.disable()}
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
                self.chaptersListView.reloadRows(refreshRows, columns: [0])
            }
        }
        
        btnLoopChapter.onIf(player.chapterLoopExists)
    }
    
    // When the player's segment loop has been changed externally (from the player), it invalidates the chapter loop if there is one
    func playbackLoopChanged() {
        btnLoopChapter.onIf(player.chapterLoopExists)
    }
}
