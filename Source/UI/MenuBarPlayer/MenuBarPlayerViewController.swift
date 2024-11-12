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
    
    override var nibName: NSNib.Name? {"MenuBarPlayer"}
    
    @IBOutlet weak var rootContainerBox: NSBox!
    @IBOutlet weak var presentationModesBox: NSBox!
    
    @IBOutlet weak var btnQuit: FillableImageButton!
    @IBOutlet weak var btnPresentationModes: FillableImageButton!
    @IBOutlet weak var logoImage: TintedImageView!
    
    @IBOutlet weak var btnSettings: NSButton!
    
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
    
    override var playbackPositionFont: NSFont {
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
    
    override func updateTrackTextViewFontsAndColors() {
        updateMultilineTrackTextViewFontsAndColors()
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
        menuBarPlayerColorSchemeChanged()
    }
    
    private func menuBarPlayerColorSchemeChanged() {
        
        rootContainerBox.fillColor = systemColorScheme.backgroundColor
        logoImage.colorChanged(systemColorScheme.captionTextColor)
        [btnQuit, btnPresentationModes, btnSettings].forEach {
            $0.colorChanged(systemColorScheme.buttonColor)
        }
    }
    
    override func initTheme() {
        
        super.initTheme()
        menuBarPlayerColorSchemeChanged()
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
    
    @IBAction func modularModeAction(_ sender: NSButton) {
        appModeManager.presentMode(.modular)
    }
    
    @IBAction func unifiedModeAction(_ sender: NSButton) {
        appModeManager.presentMode(.unified)
    }
    
    @IBAction func compactModeAction(_ sender: NSButton) {
        appModeManager.presentMode(.compact)
    }
    
    @IBAction func widgetModeAction(_ sender: NSButton) {
        appModeManager.presentMode(.widget)
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
