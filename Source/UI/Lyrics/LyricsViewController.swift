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

class LyricsViewController: NSViewController {
    
    override var nibName: NSNib.Name? {"Lyrics"}
    
    @IBOutlet weak var lblCaption: NSTextField!
    
    @IBOutlet weak var tabView: NSTabView!
    
    @IBOutlet weak var textView: NSTextView!
    @IBOutlet weak var textVertScroller: PrettyVerticalScroller!
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var tableVertScroller: PrettyVerticalScroller!
    
    var track: Track?
    
    var staticLyrics: String?
    
    var timedLyrics: TimedLyrics?
    var curLine: Int?
    
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
        
        messenger.subscribeAsync(to: .Player.trackTransitioned, handler: trackTransitioned(_:))
        messenger.subscribe(to: .View.changeWindowCornerRadius, handler: changeCornerRadius(to:))
        messenger.subscribe(to: .Lyrics.loadFromFile, handler: loadLyrics(fromFile:))
        messenger.subscribe(to: .Lyrics.lyricsUpdated, handler: updateForTrack(_:))
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
    
    var showingTimedLyrics: Bool {
        tabView.selectedIndex == 1
    }
    
    private func updateForTrack(_ track: Track?) {
        
        self.track = track
        
        self.timedLyrics = track?.externalOrEmbeddedTimedLyrics
        
        if timedLyrics != nil {
            
            dismissStaticLyricsText()
            showTimedLyricsView()
            
        } else if let staticLyrics = track?.lyrics {

            dismissTimedLyricsView()
            self.staticLyrics = staticLyrics
            updateStaticLyricsText()
            
        } else {
            
            let wasShowingTimedLyrics = tabView.selectedIndex == 1
            
            tabView.selectTabViewItem(at: 2)
            
            dismissStaticLyricsText()
            
            if wasShowingTimedLyrics {
                dismissTimedLyricsView()
            }
        }
    }
    
    private func trackTransitioned(_ notif: TrackTransitionNotification) {
        
        if appModeManager.isShowingLyrics {
            updateForTrack(notif.endTrack)
        }
    }
    
    func changeCornerRadius(to radius: CGFloat) {
        view.layer?.cornerRadius = radius
    }
}

extension LyricsViewController: ThemeInitialization {
    
    func initTheme() {
     
        lblCaption.font = systemFontScheme.captionFont
        lblCaption.textColor = systemColorScheme.captionTextColor
        
        view.layer?.backgroundColor = systemColorScheme.backgroundColor.cgColor
        textView.backgroundColor = systemColorScheme.backgroundColor
        tableView.setBackgroundColor(systemColorScheme.backgroundColor)
        
        textVertScroller.redraw()
        tableVertScroller.redraw()
        
        if showingTimedLyrics {
            updateTimedLyricsText()
        } else {
            updateStaticLyricsText()
        }
    }
}

extension LyricsViewController: FontSchemeObserver {
    
    func fontSchemeChanged() {
        
        lblCaption.font = systemFontScheme.captionFont
        
        if showingTimedLyrics {
            updateTimedLyricsText()
        } else {
            updateStaticLyricsText()
        }
    }
}

extension LyricsViewController: ColorSchemeObserver {
    
    func colorSchemeChanged() {

        lblCaption.textColor = systemColorScheme.captionTextColor

        view.layer?.backgroundColor = systemColorScheme.backgroundColor.cgColor
        textView.backgroundColor = systemColorScheme.backgroundColor
        tableView.setBackgroundColor(systemColorScheme.backgroundColor)
        
        textVertScroller.redraw()
        tableVertScroller.redraw()
        
        if showingTimedLyrics {
            updateTimedLyricsText()
        } else {
            updateStaticLyricsText()
        }
    }
}
