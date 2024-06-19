//
//  CompactPlayerTrackInfoViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class CompactPlayerTrackInfoViewController: TrackInfoViewController {
    
    override var nibName: NSNib.Name? {"CompactPlayerTrackInfo"}
    
    let compactPlayerCoverArtViewController: CompactPlayerCoverArtTrackInfoViewController = .init()
    
    override func initTabViewControllers() {

        tabViewControllers = [metadataViewController, lyricsViewController, compactPlayerCoverArtViewController,
                           audioViewController, fileSystemViewController]
    }
    
    override func initSubscriptions() {
        
        fontSchemesManager.registerObserver(self)
        colorSchemesManager.registerSchemeObserver(self)
        
        // Only respond to these notifications when the popover is shown, the updated track matches the displayed track,
        // and the album art field of the track was updated.
        messenger.subscribeAsync(to: .Player.trackInfoUpdated, handler: coverArtViewController.trackInfoUpdated(_:),
                                 filter: {[weak self] msg in (self?.view.window?.isVisible ?? false) &&
                                    msg.updatedTrack == TrackInfoViewContext.displayedTrack &&
                                    msg.updatedFields.contains(.art)})
        
        messenger.subscribe(to: .Player.trackInfo_refresh, handler: refresh)
    }
    
    override func updateTrackTitle() {}
    
    override func changeWindowCornerRadius(_ radius: CGFloat) {}
}
