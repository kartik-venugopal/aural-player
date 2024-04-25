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
    @IBOutlet weak var presentationModesBox: NSBox!
    
    @IBOutlet weak var btnQuit: FillableImageButton!
    @IBOutlet weak var logoImage: TintedImageView!
    
    @IBOutlet weak var btnSettings: NSButton!
    
    @IBOutlet weak var btnModularMode: RadioButton!
    @IBOutlet weak var btnUnifiedMode: RadioButton!
    @IBOutlet weak var btnCompactMode: RadioButton!
    @IBOutlet weak var btnWidgetMode: RadioButton!
    
    override var nibName: NSNib.Name? {"MenuBarPlayer"}
    
    private static let textViewDefaultPosition: NSPoint = NSPoint(x: 67, y: 66)
    private static let textViewPosition_noArt: NSPoint = NSPoint(x: 12, y: 66)
    
    private static let textViewDefaultWidth: CGFloat = 210
    private static let textViewWidth_noArt: CGFloat = 265
    
    override func setUpNotificationHandling() {
        
        super.setUpNotificationHandling()
        
        messenger.subscribe(to: .MenuBarPlayer.menuWillOpen, handler: menuWillOpen)
        messenger.subscribe(to: .MenuBarPlayer.menuDidClose, handler: menuDidClose)
    }
    
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
    
    override func showOrHideAlbumArt() {
        
        artView.showIf(menuBarPlayerUIState.showAlbumArt)
        resizeAndRepositionTextView()
    }
    
    private func resizeAndRepositionTextView() {
        
        let showingArt: Bool = menuBarPlayerUIState.showAlbumArt
        
        multilineTrackTextView.setFrameOrigin(showingArt ? Self.textViewDefaultPosition : Self.textViewPosition_noArt)
        multilineTrackTextView.resize(width: showingArt ? Self.textViewDefaultWidth : Self.textViewWidth_noArt)
        textScrollView.resize(multilineTrackTextView.width, multilineTrackTextView.height)
        multilineTrackTextView.resized()
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
        messenger.publish(.MenuBarPlayer.toggleSettingsMenu)
    }
    
    @IBAction func showOrHidePresentationModesBoxAction(_ sender: NSButton) {
        
        if presentationModesBox.isShown {
            presentationModesBox.hide()
            
        } else {
            
            presentationModesBox.bringToFront()
            presentationModesBox.show()
        }
    }
    
    @IBAction func presentationModeRadioButtonGroupAction(_ sender: RadioButton) {}
    
    @IBAction func changePresentationModeAction(_ sender: RadioButton) {
        
        if btnModularMode.isOn {
            appModeManager.presentMode(.modular)
            
        } else if btnUnifiedMode.isOn {
            appModeManager.presentMode(.unified)
            
        } else if btnCompactMode.isOn {
            appModeManager.presentMode(.compact)
            
        } else if btnWidgetMode.isOn {
            appModeManager.presentMode(.widget)
        }
    }
    
    @IBAction func quitAction(_ sender: AnyObject) {
        NSApp.terminate(self)
    }
    
    // MARK: Menu delegate functions (menu bar menu) ---------------------------------
    
    private func menuWillOpen() {
        
        // If the player is playing, we need to resume updating the seek
        // position as the view is now visible.
        updateSeekPosition()
        updateSeekTimerState()
    }
    
    private func menuDidClose() {
        
        // Updating seek position is not necessary when the view has been closed.
        setSeekTimerState(to: false)
    }
}
