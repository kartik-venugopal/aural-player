//
//  MenuBarPlayerViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class MenuBarPlayerViewController: PlayerViewController {
    
    @IBOutlet weak var rootContainerBox: NSBox!
    @IBOutlet weak var btnQuit: FillableImageButton!
    @IBOutlet weak var logoImage: TintedImageView!
    
    @IBOutlet weak var btnSettings: NSButton!
    
    override var nibName: NSNib.Name? {"MenuBarPlayer"}
    
//    private lazy var settingsPopup: MenuBarSettingsPopupViewController = .instance
    
    override var shouldEnableSeekTimer: Bool {
        super.shouldEnableSeekTimer && view.superview != nil
    }
    
    override var showTrackTime: Bool {
        compactPlayerUIState.showTrackTime
    }
    
    override var trackTimeFont: NSFont {
        systemFontScheme.smallFont
    }
    
    override var displaysChapterIndicator: Bool {
        false
    }
    
    override func updateTrackTextView(for track: Track?, playingChapterTitle: String? = nil) {
        updateMultilineTrackTextView(for: track, playingChapterTitle: playingChapterTitle)
    }
    
    override var multilineTrackTextTitleFont: NSFont {
        systemFontScheme.normalFont
    }
    
    override var multilineTrackTextArtistAlbumFont: NSFont {
        systemFontScheme.smallFont
    }
    
    override func updateTrackTextViewFonts() {
        updateMultilineTrackTextViewFonts()
    }
    
    override func updateTrackTextViewColors() {
        updateMultilineTrackTextViewColors()
    }
    
    override func colorSchemeChanged() {
        
        super.colorSchemeChanged()
        
        rootContainerBox.fillColor = systemColorScheme.backgroundColor
        logoImage.colorChanged(systemColorScheme.captionTextColor)
        [btnQuit, btnSettings].forEach {
            $0.colorChanged(systemColorScheme.buttonColor)
        }
    }
    
    @IBAction func toggleSettingsMenuAction(_ sender: NSButton) {
        
//        messenger.publish(.MenuBarPlayer.showSettings)
        
//        if settingsPopup.isShown {
//            settingsPopup.close()
//        } else {
//            settingsPopup.show(relativeTo: self.view, preferredEdge: .maxX)
//        }
    }
    
    @IBAction func quitAction(_ sender: AnyObject) {
        NSApp.terminate(self)
    }
}

extension MenuBarPlayerViewController: NSMenuDelegate {
    
    func menuDidClose(_ menu: NSMenu) {
        
        // Updating seek position is not necessary when the view has been closed.
        setSeekTimerState(to: false)
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        
        // If the player is playing, we need to resume updating the seek
        // position as the view is now visible.
        updateSeekPosition()
        updateSeekTimerState()
    }
}
