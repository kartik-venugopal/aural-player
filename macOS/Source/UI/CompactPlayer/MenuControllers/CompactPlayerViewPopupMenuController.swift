//
//  CompactPlayerViewPopupMenuController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class CompactPlayerViewPopupMenuController: NSObject, NSMenuDelegate {
    
    @IBOutlet weak var showPlayerMenuItem: NSMenuItem!
    @IBOutlet weak var showPlayQueueMenuItem: NSMenuItem!
    @IBOutlet weak var showChaptersListMenuItem: NSMenuItem!
    @IBOutlet weak var toggleEffectsMenuItem: NSMenuItem!
    @IBOutlet weak var showTrackInfoMenuItem: NSMenuItem!
    
    @IBOutlet weak var scrollingEnabledMenuItem: NSMenuItem!
    @IBOutlet weak var showTrackTimeMenuItem: NSMenuItem!
    @IBOutlet weak var seekPositionDisplayTypeMenuItem: NSMenuItem!
    
    @IBOutlet weak var timeElapsedMenuItem: TrackTimeDisplayTypeMenuItem!
    @IBOutlet weak var timeRemainingMenuItem: TrackTimeDisplayTypeMenuItem!
    @IBOutlet weak var trackDurationMenuItem: TrackTimeDisplayTypeMenuItem!
    
    var seekPositionDisplayTypeItems: [NSMenuItem] = []
    
    @IBOutlet weak var cornerRadiusStepper: NSStepper!
    @IBOutlet weak var lblCornerRadius: NSTextField!
    
    private lazy var messenger = Messenger(for: self)
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        // View settings menu items
        timeElapsedMenuItem.displayType = .elapsed
        timeRemainingMenuItem.displayType = .remaining
        trackDurationMenuItem.displayType = .duration
        
        seekPositionDisplayTypeItems = [timeElapsedMenuItem, timeRemainingMenuItem, trackDurationMenuItem]
    }
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        [showPlayerMenuItem, showPlayQueueMenuItem, toggleEffectsMenuItem, showChaptersListMenuItem, showTrackInfoMenuItem].forEach {$0?.off()}

        switch compactPlayerUIState.displayedView {
            
        case .player:
            showPlayerMenuItem.on()
            
        case .playQueue, .search:
            showPlayQueueMenuItem.on()
            
        case .chaptersList:
            showChaptersListMenuItem.on()
            
        case .effects:
            toggleEffectsMenuItem.on()
            
        case .trackInfo:
            showTrackInfoMenuItem.on()
        }
        
        let isPlaying = playbackInfoDelegate.state.isPlayingOrPaused

        // Cannot show Track Info view if no track is currently playing
        showTrackInfoMenuItem.showIf(compactPlayerUIState.displayedView == .trackInfo || isPlaying)
        
        showChaptersListMenuItem.enableIf(isPlaying && playbackInfoDelegate.chapterCount > 0)
        
        scrollingEnabledMenuItem.onIf(compactPlayerUIState.trackInfoScrollingEnabled)
        showTrackTimeMenuItem.onIf(compactPlayerUIState.showTrackTime)
        seekPositionDisplayTypeMenuItem.showIf(compactPlayerUIState.showTrackTime)
        
        if compactPlayerUIState.showTrackTime {
            
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
        
        cornerRadiusStepper.integerValue = compactPlayerUIState.cornerRadius.roundedInt
        lblCornerRadius.stringValue = "\(cornerRadiusStepper.integerValue)px"
    }
    
    @IBAction func cornerRadiusStepperAction(_ sender: NSStepper) {
        
        compactPlayerUIState.cornerRadius = CGFloat(cornerRadiusStepper.floatValue)
        lblCornerRadius.stringValue = "\(cornerRadiusStepper.integerValue)px"
        
        messenger.publish(.CompactPlayer.changeWindowCornerRadius)
    }
    
    // Shows the Player view
    @IBAction func showPlayerAction(_ sender: AnyObject) {
        messenger.publish(.CompactPlayer.showPlayer)
    }
 
    // Shows the Play Queue view
    @IBAction func showPlayQueueAction(_ sender: AnyObject) {
        messenger.publish(.CompactPlayer.showPlayQueue)
    }
    
    // Shows/hides the effects view
    @IBAction func toggleEffectsAction(_ sender: AnyObject) {
        messenger.publish(.CompactPlayer.toggleEffects)
    }
    
    // Shows the Chapters List view
    @IBAction func showChaptersListAction(_ sender: AnyObject) {
        messenger.publish(.CompactPlayer.showChaptersList)
    }
    
    // Shows the Track Info view
    @IBAction func showTrackInfoAction(_ sender: AnyObject) {
        messenger.publish(.Player.trackInfo)
    }
    
    // MARK: Player view actions ------------------------------------------------------------------------
    
    @IBAction func toggleTrackInfoScrollingAction(_ sender: NSMenuItem) {
        
        compactPlayerUIState.trackInfoScrollingEnabled.toggle()
        messenger.publish(.CompactPlayer.toggleTrackInfoScrolling)
    }
    
    @IBAction func toggleShowSeekPositionAction(_ sender: NSMenuItem) {
        
        compactPlayerUIState.showTrackTime.toggle()
        messenger.publish(.CompactPlayer.toggleShowSeekPosition)
    }
    
    @IBAction func changeSeekPositionDisplayTypeAction(_ sender: TrackTimeDisplayTypeMenuItem) {
        
        playerUIState.trackTimeDisplayType = sender.displayType
        messenger.publish(.Player.setTrackTimeDisplayType, payload: sender.displayType)
    }
}
