//
//  WidgetPlayerViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class WidgetPlayerViewController: PlayerViewController {
    
    @IBOutlet weak var scrollingEnabledMenuItem: NSMenuItem!
    @IBOutlet weak var showPlaybackPositionMenuItem: NSMenuItem!
    @IBOutlet weak var seekPositionDisplayTypeMenuItem: NSMenuItem!
    
    @IBOutlet weak var timeElapsedMenuItem: PlaybackPositionDisplayTypeMenuItem!
    @IBOutlet weak var timeRemainingMenuItem: PlaybackPositionDisplayTypeMenuItem!
    @IBOutlet weak var trackDurationMenuItem: PlaybackPositionDisplayTypeMenuItem!
    
    private lazy var seekPositionDisplayTypeItems: [NSMenuItem] = [timeElapsedMenuItem, timeRemainingMenuItem, trackDurationMenuItem]
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        // View settings menu items
        timeElapsedMenuItem.displayType = .elapsed
        timeRemainingMenuItem.displayType = .remaining
        trackDurationMenuItem.displayType = .duration
    }
    
    override var showPlaybackPosition: Bool {
        widgetPlayerUIState.showPlaybackPosition
    }
    
    override var displaysChapterIndicator: Bool {
        false
    }
    
    override func updateTrackTextView(for track: Track?, playingChapterTitle: String? = nil) {
        updateScrollingTrackTextView(for: track)
    }
    
    override func updateTrackTextViewFonts() {
        updateScrollingTrackTextViewFonts()
    }
    
    override func updateTrackTextViewColors() {
        updateScrollingTrackTextViewColors()
    }
    
    override func updateTrackTextViewFontsAndColors() {
        updateScrollingTrackTextViewFontsAndColors()
    }
    
    override func setUpTrackInfoView() {
        
        super.setUpTrackInfoView()
        setUpScrollingTrackInfoView()
    }
    
    override func showOrHidePlaybackPosition() {
        
        super.showOrHidePlaybackPosition()
        layoutScrollingTrackTextView()
    }
    
    func windowResized() {
        layoutScrollingTrackTextView()
    }
    
    @IBAction func toggleTrackInfoScrollingAction(_ sender: NSMenuItem) {
        
        widgetPlayerUIState.trackInfoScrollingEnabled = scrollingTrackTextView.scrollingEnabled
        scrollingTrackTextView.scrollingEnabled.toggle()
    }
    
    @IBAction func toggleShowSeekPositionAction(_ sender: NSMenuItem) {
        
        widgetPlayerUIState.showPlaybackPosition.toggle()
        layoutScrollingTrackTextView()
    }
    
    @IBAction func changeSeekPositionDisplayTypeAction(_ sender: PlaybackPositionDisplayTypeMenuItem) {
        
        playerUIState.playbackPositionDisplayType = sender.displayType
        setPlaybackPositionDisplayType(to: playerUIState.playbackPositionDisplayType)
    }
    
    override func updateDuration(for track: Track?) {
        
        updateSeekPosition()
        layoutScrollingTrackTextView()
    }
}

extension WidgetPlayerViewController: NSMenuDelegate {
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        scrollingEnabledMenuItem.onIf(widgetPlayerUIState.trackInfoScrollingEnabled)
        
        seekPositionDisplayTypeMenuItem.showIf(widgetPlayerUIState.showPlaybackPosition)
        
        showPlaybackPositionMenuItem.onIf(widgetPlayerUIState.showPlaybackPosition)
        guard widgetPlayerUIState.showPlaybackPosition else {return}
        
        seekPositionDisplayTypeItems.forEach {$0.off()}
        
        switch playerUIState.playbackPositionDisplayType {
        
        case .elapsed:
            
            timeElapsedMenuItem.on()
            
        case .remaining:
            
            timeRemainingMenuItem.on()
            
        case .duration:
            
            trackDurationMenuItem.on()
        }
    }
}

class PlaybackPositionDisplayTypeMenuItem: NSMenuItem {
    var displayType: PlaybackPositionDisplayType = .elapsed
}
