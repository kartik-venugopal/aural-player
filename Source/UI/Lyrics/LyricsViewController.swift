//
// LyricsViewController.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import AppKit
import LyricsCore
import LyricsService

class LyricsViewController: NSViewController {
    
    override var nibName: NSNib.Name? {"Lyrics"}
    
    @IBOutlet weak var imgLyrics: NSImageView!
    @IBOutlet weak var lblCaption: NSTextField!
    
    @IBOutlet weak var tabView: NSTabView!
    
    @IBOutlet weak var textView: NSTextView!
    @IBOutlet weak var textVertScroller: PrettyVerticalScroller!
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var tableVertScroller: PrettyVerticalScroller!
    
    @IBOutlet weak var lblDragDrop: NSTextField!
    @IBOutlet weak var btnChooseFile: NSButton!
    @IBOutlet weak var btnSearchOnline: NSButton!
    
    @IBOutlet weak var lblSearching: NSTextField!
    @IBOutlet weak var searchSpinner: NSProgressIndicator!
    
    var track: Track?
    
    var staticLyrics: String?
    
    var timedLyrics: TimedLyrics?
    var curLine: Int?
    var curSegment: Int?
    
    lazy var messenger = Messenger(for: self)
    
    lazy var timer: RepeatingTaskExecutor = RepeatingTaskExecutor(intervalMillis: (1000 / (100 * audioGraphDelegate.timeStretchUnit.effectiveRate)).roundedInt,
                                                                      task: {[weak self] in
        self?.highlightCurrentLine()},
                                                                      queue: .main)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.wantsLayer = true
        
        changeCornerRadius(to: playerUIState.cornerRadius)
        
        fontSchemesManager.registerObserver(self)
        colorSchemesManager.registerSchemeObservers(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.buttonColor, changeReceivers: [imgLyrics, btnChooseFile, btnSearchOnline])
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.primaryTextColor, changeReceivers: [lblDragDrop, btnChooseFile, btnSearchOnline])
        
        messenger.subscribeAsync(to: .Player.trackTransitioned, handler: trackTransitioned(_:))
        
        messenger.subscribeAsync(to: .Player.trackInfoUpdated, handler: lyricsLoaded(notif:), filter: {notif in
            notif.updatedFields.contains(.lyrics)
        })
        
        messenger.subscribe(to: .Lyrics.loadFromFile, handler: loadLyrics(fromFile:))
        messenger.subscribe(to: .Lyrics.searchForLyricsOnline, handler: searchForLyricsOnline, filter: {
            appModeManager.isShowingLyrics
        })
        messenger.subscribe(to: .View.changeWindowCornerRadius, handler: changeCornerRadius(to:))
    }
    
    override func viewWillAppear() {
        
        super.viewWillAppear()
        updateForTrack(playbackInfoDelegate.playingTrack)
    }
    
    override func viewDidDisappear() {
        
        super.viewDidDisappear()
        
        dismissStaticLyricsText()
        dismissTimedLyricsView()
    }
    
    var showingStaticLyrics: Bool {
        tabView.selectedIndex == 0
    }
    
    var showingTimedLyrics: Bool {
        tabView.selectedIndex == 1
    }
    
    func updateForTrack(_ track: Track?) {
        
        self.track = track
        
        self.timedLyrics = track?.externalOrEmbeddedTimedLyrics
        doUpdate()
    }
    
    func doUpdate() {
        
        if timedLyrics != nil {
            
            dismissStaticLyricsText()
            showTimedLyricsView()
            
        } else if let staticLyrics = track?.lyrics {

            dismissTimedLyricsView()
            self.staticLyrics = staticLyrics
            updateStaticLyricsText()
            
        } else {
            
            let wasShowingTimedLyrics = tabView.selectedIndex == 1
            
            tabView.selectTabViewItem(at: track == nil ? 3 : 2)
            searchSpinner.stopAnimation(nil)
            
            dismissStaticLyricsText()
            
            if wasShowingTimedLyrics {
                dismissTimedLyricsView()
            }
        }
    }
    
    func trackTransitioned(_ notif: TrackTransitionNotification) {
        
        if appModeManager.isShowingLyrics {
            updateForTrack(notif.endTrack)
        }
    }
    
    func changeCornerRadius(to radius: CGFloat) {
        view.layer?.cornerRadius = radius
    }
}
