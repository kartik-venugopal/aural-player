//
//  CompactPlayerViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class CompactPlayerViewController: PlayerViewController {
    
    override var nibName: NSNib.Name? {"CompactPlayer"}
    
    @IBOutlet weak var functionsMenuContainerBox: NSBox!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        startTrackingView(options: [.activeAlways, .mouseEnteredAndExited])
    }
    
    override var showTrackTime: Bool {
        compactPlayerUIState.showTrackTime
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
    
    override func showOrHideTrackTime() {
        
        super.showOrHideTrackTime()
        layoutScrollingTrackTextView()
    }
    
    override func setUpScrollingTrackInfoView() {
        
        layoutScrollingTrackTextView()
        scrollingTrackTextView.scrollingEnabled = compactPlayerUIState.trackInfoScrollingEnabled
    }
    
    override func layoutScrollingTrackTextView() {
        
        let showTrackTime: Bool = compactPlayerUIState.showTrackTime
        
        scrollingTextViewContainerBox.setFrameSize(NSSize(width: showTrackTime ? 200 : 280, height: 26))
        scrollingTrackTextView.setFrameSize(NSSize(width: showTrackTime ? 200 : 280, height: 26))
        
        scrollingTrackTextView.update()
    }
    
    @IBAction func toggleTrackInfoScrollingAction(_ sender: NSMenuItem) {
        
        compactPlayerUIState.trackInfoScrollingEnabled = scrollingTrackTextView.scrollingEnabled
        scrollingTrackTextView.scrollingEnabled.toggle()
    }
    
    @IBAction func toggleShowSeekPositionAction(_ sender: NSMenuItem) {
        
        compactPlayerUIState.showTrackTime.toggle()
        layoutScrollingTrackTextView()
    }
    
    @IBAction func changeSeekPositionDisplayTypeAction(_ sender: TrackTimeDisplayTypeMenuItem) {
        
        playerUIState.trackTimeDisplayType = sender.displayType
        setTrackTimeDisplayType(to: playerUIState.trackTimeDisplayType)
    }
    
    override func showTrackInfoView() {
        messenger.publish(.CompactPlayer.showTrackInfo)
    }
    
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
