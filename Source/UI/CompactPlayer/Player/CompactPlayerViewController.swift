//
//  CompactPlayerViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class CompactPlayerViewController: PlayerViewController {
    
    override var nibName: NSNib.Name? {"CompactPlayer"}
    
    @IBOutlet weak var functionsMenuContainerBox: NSBox!
    @IBOutlet weak var functionsMenuDelegate: PlayingTrackFunctionsMenuDelegate!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        startTrackingView(options: [.activeAlways, .mouseEnteredAndExited])
    }
    
    override func destroy() {
        
        super.destroy()
        functionsMenuDelegate.destroy()
    }
    
    override func setUpCommandHandling() {
        
        super.setUpCommandHandling()
        
        messenger.subscribe(to: .CompactPlayer.toggleTrackInfoScrolling, handler: toggleTrackInfoScrolling)
        messenger.subscribe(to: .View.toggleTrackInfo, handler: showTrackInfo)
    }
    
    override var showPlaybackPosition: Bool {
        playerUIState.showPlaybackPosition
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
    
    override func setUpScrollingTrackInfoView() {
        
        layoutScrollingTrackTextView()
        scrollingTrackTextView.scrollingEnabled = compactPlayerUIState.trackInfoScrollingEnabled
    }
    
    override func layoutScrollingTrackTextView() {
        
        let showPlaybackPosition: Bool = playerUIState.showPlaybackPosition
        
        scrollingTextViewContainerBox.setFrameSize(NSSize(width: showPlaybackPosition ? 200 : 280, height: 26))
        scrollingTrackTextView.setFrameSize(NSSize(width: showPlaybackPosition ? 200 : 280, height: 26))
        
        scrollingTrackTextView.update()
    }
    
    @IBAction func toggleTrackInfoScrollingAction(_ sender: NSMenuItem) {
        toggleTrackInfoScrolling()
    }
    
    private func toggleTrackInfoScrolling() {
        
        compactPlayerUIState.trackInfoScrollingEnabled = scrollingTrackTextView.scrollingEnabled
        scrollingTrackTextView.scrollingEnabled.toggle()
    }
    
    @IBAction func toggleShowSeekPositionAction(_ sender: NSMenuItem) {
        
        playerUIState.showPlaybackPosition.toggle()
        layoutScrollingTrackTextView()
    }
    
    @IBAction func changeSeekPositionDisplayTypeAction(_ sender: PlaybackPositionDisplayTypeMenuItem) {
        
        playerUIState.playbackPositionDisplayType = sender.displayType
        setPlaybackPositionDisplayType(to: playerUIState.playbackPositionDisplayType)
    }
    
//    override func showTrackInfoView() {
//        messenger.publish(.View.toggleTrackInfo)
//    }
    
    // MARK: Auto-hide of playing track functions menu button ----------------------------------------
    
    override func mouseEntered(with event: NSEvent) {
        
        if playbackInfoDelegate.playingTrack != nil {
            functionsMenuContainerBox.show()
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        functionsMenuContainerBox.hide()
    }
    
    override func trackChanged(to newTrack: Track?) {
        
        super.trackChanged(to: newTrack)
        
        // When the track changes,
        // - Hide the functions box if no new track
        // - If new track, show the box if the mouse cursor is over the view
        
        if newTrack == nil {
            functionsMenuContainerBox.hide()
        } else if let mouseLoc = view.window?.mouseLocationOutsideOfEventStream, view.frame.contains(mouseLoc) {
            functionsMenuContainerBox.show()
        }
    }
}
