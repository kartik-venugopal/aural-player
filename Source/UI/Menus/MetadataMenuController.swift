//
// MetadataMenuController.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import AppKit

class MetadataMenuController: NSObject, NSMenuDelegate {
    
    @IBOutlet weak var detailedInfoMenuItem: NSMenuItem!
    @IBOutlet weak var addLyricsFileMenuItem: NSMenuItem!
    @IBOutlet weak var searchForLyricsOnlineMenuItem: NSMenuItem!
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        let isPlayingOrPaused = playbackInfoDelegate.state.isPlayingOrPaused
        [detailedInfoMenuItem, addLyricsFileMenuItem, searchForLyricsOnlineMenuItem].forEach {$0?.enableIf(isPlayingOrPaused)}
    }
    
    @IBAction func moreInfoAction(_ sender: AnyObject) {
        Messenger.publish(.Player.trackInfo)
    }
    
    @IBAction func addLyricsFileAction(_ sender: AnyObject) {
        Messenger.publish(.Lyrics.addLyricsFile)
    }
    
    @IBAction func searchForLyricsOnlineAction(_ sender: AnyObject) {
        Messenger.publish(.Lyrics.searchForLyricsOnline)
    }
}
