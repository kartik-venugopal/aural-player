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
import MusicPlayer

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
    
    func updateForTrack(_ track: Track?) {
        
        self.track = track
        
        self.timedLyrics = track?.externalOrEmbeddedTimedLyrics
        
        if let track, timedLyrics == nil {
            searchForLyricsOnline(for: track)
        }
        
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
            
            tabView.selectTabViewItem(at: 2)
            
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
    
    var onlineSearchEnabled: Bool {
        preferences.metadataPreferences.lyrics.enableAutoSearch.value
    }
    
    private func searchForLyricsOnline(for track: Track) {
        
        guard onlineSearchEnabled else {return}
        
        let searchService = LyricsSearchService()
        
        Task.detached(priority: .userInitiated) {
            
            if let bestLyrics = await searchService.searchLyrics(for: track) {

                // Update the UI
                await MainActor.run {
                    
                    self.timedLyrics = TimedLyrics(from: bestLyrics, trackDuration: track.duration)
                    self.doUpdate()
                }
                
                if let cachedLyricsFile = bestLyrics.persistToFile(track.defaultDisplayName) {
                    track.metadata.externalLyricsFile = cachedLyricsFile
                }
            }
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

fileprivate extension LyricsSearchService {
    
    func searchLyrics(for track: Track) async -> Lyrics? {
        
        let musicTrack = MusicTrack(
            id: track.defaultDisplayName,
            title: track.title,
            album: track.album,
            artist: track.artist,
            duration: track.duration,
            fileURL: track.file,
            artwork: track.art?.originalImage?.image,
            originalTrack: track
        )
        
        let allLyrics = await searchLyrics(with: musicTrack.searchQuery)
        return allLyrics.bestMatch(for: musicTrack)
    }
}
