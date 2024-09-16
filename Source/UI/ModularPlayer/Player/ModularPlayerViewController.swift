//
//  ModularPlayerViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class ModularPlayerViewController: PlayerViewController {
    
    override var nibName: NSNib.Name? {"ModularPlayer"}
    
    @IBOutlet weak var infoBox: NSBox!
    @IBOutlet weak var controlsBox: NSBox!
    @IBOutlet weak var btnFunctionsMenu: NSPopUpButton!
    @IBOutlet weak var functionsMenuDelegate: PlayingTrackFunctionsMenuDelegate!
    
    private lazy var controlsBoxConstraints: LayoutConstraintsManager = LayoutConstraintsManager(for: controlsBox)
    
    override var shouldEnableSeekTimer: Bool {
        
        if playbackDelegate.state != .playing {
            return false
        }
        
        // Check if we need to update seek slider position
        if playerUIState.showControls {
            return true
        }
        
        // Assume controls are hidden
        
        // Check if we need to update track time
        if playerUIState.showPlaybackPosition && playerUIState.playbackPositionDisplayType != .duration {
            return true
        }
        
        // Assume no need to update track time
        
        // Check if we need to check current chapter (i.e. seekTimerTaskQueue)
        if seekTimerTaskQueue.hasTasks {
            return true
        }
        
        return false
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        controlsBoxConstraints.setBottom(relatedToBottomOf: self.view, offset: -7)
        controlsBoxConstraints.setHeight(80)
        
        controlsBoxConstraints.setLeading(relatedToLeadingOf: self.view)
        controlsBoxConstraints.setTrailing(relatedToTrailingOf: self.view)
        
        // TODO: Re-do this on view resize
        startTrackingView(options: [.activeAlways, .mouseEnteredAndExited])
    }
    
    override func updateTrackTextView(for track: Track?, playingChapterTitle: String? = nil) {
        updateMultilineTrackTextView(for: track, playingChapterTitle: playingChapterTitle)
    }
    
    override func updateTrackTextViewFonts() {
        updateMultilineTrackTextViewFonts()
    }
    
    override func updateTrackTextViewColors() {
        updateMultilineTrackTextViewColors()
    }
    
    override func updateMultilineTrackTextViewColors() {
        
        super.updateMultilineTrackTextViewColors()
        
        infoBox.fillColor = systemColorScheme.backgroundColor
        controlsBox.fillColor = systemColorScheme.backgroundColor
        
        btnFunctionsMenu.colorChanged(systemColorScheme.buttonColor)
    }
    
    override func updateTrackTextViewFontsAndColors() {
        updateMultilineTrackTextViewFontsAndColors()
    }
    
    override func updateMultilineTrackTextViewFontsAndColors() {
        
        super.updateMultilineTrackTextViewFontsAndColors()
        
        infoBox.fillColor = systemColorScheme.backgroundColor
        controlsBox.fillColor = systemColorScheme.backgroundColor
        
        btnFunctionsMenu.colorChanged(systemColorScheme.buttonColor)
    }
    
    override func updateTrackInfo(for track: Track?, playingChapterTitle: String? = nil) {
        
        super.updateTrackInfo(for: track, playingChapterTitle: playingChapterTitle)
        artView.showIf(playerUIState.showAlbumArt)
    }
    
    override func showTrackInfoView() {
        
        if windowLayoutsManager.isWindowLoaded(withId: .trackInfo) {
            messenger.publish(.Player.trackInfo_refresh)
        }
        
        windowLayoutsManager.showWindow(withId: .trackInfo)
    }
    
    override func setUpColorSchemePropertyObservation() {
        
        super.setUpColorSchemePropertyObservation()
        
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, changeReceivers: [infoBox, controlsBox])
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, handler: multilineTrackTextView.backgroundColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperties: [\.primaryTextColor, \.secondaryTextColor, \.tertiaryTextColor], changeReceiver: multilineTrackTextView)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.secondaryTextColor, handler: artViewTintColorChanged(_:))
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.buttonColor, changeReceiver: btnFunctionsMenu)
    }
    
    override func trackChanged(to newTrack: Track?) {
        
        super.trackChanged(to: newTrack)
        
        // If playback stopped, hide/dismiss the functions menu.
        if newTrack == nil {
            
            btnFunctionsMenu.hide()
            btnFunctionsMenu.menu?.cancelTracking()
        }
    }
    
    override func destroy() {
        
        super.destroy()
        functionsMenuDelegate.destroy()
    }
}
