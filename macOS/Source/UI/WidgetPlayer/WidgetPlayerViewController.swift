//
//  WidgetPlayerViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class WidgetPlayerViewController: PlayerViewController {
    
    @IBOutlet weak var scrollingEnabledMenuItem: NSMenuItem!
    @IBOutlet weak var showTrackTimeMenuItem: NSMenuItem!
    @IBOutlet weak var seekPositionDisplayTypeMenuItem: NSMenuItem!
    
    @IBOutlet weak var timeElapsedMenuItem: SeekPositionDisplayTypeMenuItem!
    @IBOutlet weak var timeRemainingMenuItem: SeekPositionDisplayTypeMenuItem!
    @IBOutlet weak var trackDurationMenuItem: SeekPositionDisplayTypeMenuItem!
    
    private lazy var seekPositionDisplayTypeItems: [NSMenuItem] = [timeElapsedMenuItem, timeRemainingMenuItem, trackDurationMenuItem]
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        // View settings menu items
        timeElapsedMenuItem.displayType = .elapsed
        timeRemainingMenuItem.displayType = .remaining
        trackDurationMenuItem.displayType = .duration
    }
    
    override var showTrackTime: Bool {
        widgetPlayerUIState.showTrackTime
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
    
    override func setUpTrackInfoView() {
        
        super.setUpTrackInfoView()
        setUpScrollingTrackInfoView()
    }
    
    override func showOrHideTrackTime() {
        
        super.showOrHideTrackTime()
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
        
        widgetPlayerUIState.showTrackTime.toggle()
        layoutScrollingTrackTextView()
    }
    
    @IBAction func changeSeekPositionDisplayTypeAction(_ sender: SeekPositionDisplayTypeMenuItem) {
        
        playerUIState.trackTimeDisplayType = sender.displayType
        setTrackTimeDisplayType(to: playerUIState.trackTimeDisplayType)
    }
    
    override func updateDuration(for track: Track?) {
        
        updateSeekPosition()
        layoutScrollingTrackTextView()
    }
}

extension WidgetPlayerViewController: NSMenuDelegate {
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        scrollingEnabledMenuItem.onIf(widgetPlayerUIState.trackInfoScrollingEnabled)
        
        seekPositionDisplayTypeMenuItem.showIf(widgetPlayerUIState.showTrackTime)
        
        showTrackTimeMenuItem.onIf(widgetPlayerUIState.showTrackTime)
        guard widgetPlayerUIState.showTrackTime else {return}
        
        seekPositionDisplayTypeItems.forEach {$0.off()}
        
        switch playerUIState.trackTimeDisplayType {
        
        case .elapsed:
            
            timeElapsedMenuItem.on()
            
        case .remaining:
            
            timeRemainingMenuItem.on()
            
        case .duration:
            
            trackDurationMenuItem.on()
        }
    }
}

class SeekPositionDisplayTypeMenuItem: NSMenuItem {
    var displayType: TrackTimeDisplayType = .elapsed
}
