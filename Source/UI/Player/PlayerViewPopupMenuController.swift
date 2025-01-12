//
//  PlayerViewPopupMenuController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Handles requests to show/hide or adjust different fields in the player view.
    e.g. show/hide album art or adjust seek time format.
 */
class PlayerViewPopupMenuController: NSObject, NSMenuDelegate {

    @IBOutlet weak var showArtMenuItem: NSMenuItem!
    @IBOutlet weak var showArtistMenuItem: NSMenuItem!
    @IBOutlet weak var showAlbumMenuItem: NSMenuItem!
    @IBOutlet weak var showCurrentChapterMenuItem: NSMenuItem!
    
    // Only in Compact mode
    @IBOutlet weak var scrollTrackInfoMenuItem: NSMenuItem!
    
    @IBOutlet weak var showMainControlsMenuItem: NSMenuItem!
    @IBOutlet weak var showPlaybackPositionMenuItem: NSMenuItem!
    
    @IBOutlet weak var playbackPositionDisplayTypeMenuItem: NSMenuItem!
    @IBOutlet weak var playbackPositionElapsedMenuItem: NSMenuItem!
    @IBOutlet weak var playbackPositionRemainingMenuItem: NSMenuItem!
    @IBOutlet weak var playbackPositionTrackDurationMenuItem: NSMenuItem!
    
    // When the menu is about to open, set the menu item states according to the current window/view state
    func menuWillOpen(_ menu: NSMenu) {
        
        guard appModeManager.currentMode != .compact else {
            
            updateForCompactMode()
            return
        }
        
        // Player view:
        
        var hasArtist: Bool = false
        var hasAlbum: Bool = false
        var hasChapters: Bool = false
        
        if let track = playbackInfoDelegate.playingTrack {
            
            hasArtist = track.artist != nil
            hasAlbum = track.album != nil
            hasChapters = track.hasChapters
        }
        
        showArtMenuItem.onIf(playerUIState.showAlbumArt)
        
        showArtistMenuItem.showIf(hasArtist)
        showArtistMenuItem.onIf(playerUIState.showArtist)
        
        showAlbumMenuItem.showIf(hasAlbum)
        showAlbumMenuItem.onIf(playerUIState.showAlbum)
        
        showCurrentChapterMenuItem.showIf(hasChapters)
        showCurrentChapterMenuItem.onIf(playerUIState.showCurrentChapter)
        
        scrollTrackInfoMenuItem.showIf(appModeManager.currentMode == .compact)
        scrollTrackInfoMenuItem.onIf(compactPlayerUIState.trackInfoScrollingEnabled)
        
        showMainControlsMenuItem.onIf(playerUIState.showControls)
        
        updatePlaybackPositionAndDisplayType()
    }
    
    private func updateForCompactMode() {
        
        [showArtMenuItem, showArtistMenuItem, showAlbumMenuItem, showCurrentChapterMenuItem, showMainControlsMenuItem].forEach {
            $0?.hide()
        }
        
        showPlaybackPositionMenuItem.title = "Show playback position"
        
        scrollTrackInfoMenuItem.onIf(compactPlayerUIState.trackInfoScrollingEnabled)
        showPlaybackPositionMenuItem.onIf(playerUIState.showPlaybackPosition)
        
        updatePlaybackPositionAndDisplayType()
    }
    
    private func updatePlaybackPositionAndDisplayType() {
        
        showPlaybackPositionMenuItem.onIf(playerUIState.showPlaybackPosition)
        playbackPositionDisplayTypeMenuItem.showIf(playerUIState.showPlaybackPosition)
        
        guard playerUIState.showPlaybackPosition else {return}
        
        [playbackPositionElapsedMenuItem, playbackPositionRemainingMenuItem, playbackPositionTrackDurationMenuItem].forEach {$0.off()}
        
        switch playerUIState.playbackPositionDisplayType {
            
        case .elapsed:          playbackPositionElapsedMenuItem.on()
            
        case .remaining:        playbackPositionRemainingMenuItem.on()
            
        case .duration:         playbackPositionTrackDurationMenuItem.on()
            
        }
    }
    
    @IBAction func showOrHideAlbumArtAction(_ sender: NSMenuItem) {
        
        playerUIState.showAlbumArt.toggle()
        Messenger.publish(.Player.showOrHideAlbumArt)
    }
    
    @IBAction func showOrHideArtistAction(_ sender: NSMenuItem) {
        
        playerUIState.showArtist.toggle()
        Messenger.publish(.Player.showOrHideArtist)
    }
    
    @IBAction func showOrHideAlbumAction(_ sender: NSMenuItem) {
        
        playerUIState.showAlbum.toggle()
        Messenger.publish(.Player.showOrHideAlbum)
    }
    
    @IBAction func showOrHideCurrentChapterAction(_ sender: NSMenuItem) {
        
        playerUIState.showCurrentChapter.toggle()
        Messenger.publish(.Player.showOrHideCurrentChapter)
    }
    
    @IBAction func toggleTrackInfoScrollingAction(_ sender: NSMenuItem) {
        
        compactPlayerUIState.trackInfoScrollingEnabled.toggle()
        Messenger.publish(.CompactPlayer.toggleTrackInfoScrolling)
    }
    
    @IBAction func showOrHideMainControlsAction(_ sender: NSMenuItem) {
        
        playerUIState.showControls.toggle()
        Messenger.publish(.Player.showOrHideMainControls)
    }
    
    @IBAction func showOrHidePlaybackPositionAction(_ sender: NSMenuItem) {
        
        playerUIState.showPlaybackPosition.toggle()
        Messenger.publish(.Player.showOrHidePlaybackPosition)
    }
    
    @IBAction func playbackPositionElapsedDisplayTypeAction(_ sender: NSMenuItem) {
        setPlaybackPositionDisplayType(to: .elapsed)
    }
    
    @IBAction func playbackPositionRemainingDisplayTypeAction(_ sender: NSMenuItem) {
        setPlaybackPositionDisplayType(to: .remaining)
    }
    
    @IBAction func playbackPositionDurationDisplayTypeAction(_ sender: NSMenuItem) {
        setPlaybackPositionDisplayType(to: .duration)
    }
    
    private func setPlaybackPositionDisplayType(to type: PlaybackPositionDisplayType) {
        
        playerUIState.playbackPositionDisplayType = type
        Messenger.publish(.Player.setPlaybackPositionDisplayType, payload: type)
    }
}
