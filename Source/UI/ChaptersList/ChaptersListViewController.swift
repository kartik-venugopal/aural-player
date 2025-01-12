//
//  ChaptersListViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
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
    
    override var nibName: NSNib.Name? {"ChaptersList"}
    
    @IBOutlet weak var rootContainerBox: NSBox!
    
    @IBOutlet weak var chaptersListView: NSTableView!
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var clipView: NSClipView!
    
    @IBOutlet weak var header: NSTableHeaderView!
    
    @IBOutlet weak var lblCaption: NSTextField!
    @IBOutlet weak var lblSummary: NSTextField!
    
    @IBOutlet weak var btnPreviousChapter: TintedImageButton!
    @IBOutlet weak var btnNextChapter: TintedImageButton!
    @IBOutlet weak var btnReplayChapter: TintedImageButton!
    @IBOutlet weak var btnLoopChapter: OnOffImageButton!
    
    let player: PlaybackDelegateProtocol = playbackDelegate
    
    private lazy var messenger = Messenger(for: self)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        scrollView.drawsBackground = false
        clipView.drawsBackground = false
        
        chaptersListView.customizeHeader(heightIncrease: 5, customCellType: ChaptersListTableHeaderCell.self)
        
        if appModeManager.currentMode == .modular,
           let lblCaptionLeadingConstraint = lblCaption.superview?.constraints.first(where: {$0.firstAttribute == .leading}) {
            
            lblCaptionLeadingConstraint.constant = 23
        }
        
        // Set these fields for later access
        //        uiState.chaptersListView = self.chaptersListView
        
        initSubscriptions()
        
        btnLoopChapter.off()
    }
    
    func initSubscriptions() {
        
        fontSchemesManager.registerObserver(self)
        colorSchemesManager.registerSchemeObserver(self)
        
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, handler: backgroundColorChanged(_:))
        
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.buttonColor,
                                                     changeReceivers: [btnPreviousChapter, btnNextChapter, btnReplayChapter])
        
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
        messenger.subscribe(to: .ChaptersList.playSelectedChapter, handler: playSelectedChapter)
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
        
        guard let selRow = chaptersListView.selectedRowIndexes.first else {return}
        
        messenger.publish(.Player.playChapter, payload: selRow)
        btnLoopChapter.onIf(player.chapterLoopExists)
        
        // Remove focus from the search field (if necessary)
        self.view.window?.makeFirstResponder(chaptersListView)
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
    
    func trackChanged() {
        
        chaptersListView.reloadData()
        chaptersListView.scrollRowToVisible(0)
        
        let chapterCount: Int = player.chapterCount
        lblSummary.stringValue = String(format: "%d %@", chapterCount, chapterCount == 1 ? "chapter" : "chapters")
        
        // This should always be done
        btnLoopChapter.onIf(player.chapterLoopExists)
    }
    
    // When the currently playing chapter changes, the marker icon in the chapters list needs to move to the
    // new chapter.
    func chapterChanged(_ notification: ChapterChangedNotification) {
        
        let refreshRows: [Int] = [notification.oldChapter?.index, notification.newChapter?.index]
            .compactMap {$0}.filter({$0 >= 0})
        
        if !refreshRows.isEmpty {
            self.chaptersListView.reloadRows(refreshRows, columns: [0])
        }
        
        btnLoopChapter.onIf(player.chapterLoopExists)
    }
    
    // When the player's segment loop has been changed externally (from the player), it invalidates the chapter loop if there is one
    func playbackLoopChanged() {
        btnLoopChapter.onIf(player.chapterLoopExists)
    }
}
