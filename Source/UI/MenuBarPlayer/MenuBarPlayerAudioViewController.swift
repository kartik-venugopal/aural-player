//
//  MenuBarPlayerAudioViewController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class MenuBarPlayerAudioViewController: PlayerAudioViewController {
    
    override var showsPanControl: Bool {false}
    
    override var btnVolume: TintedImageButton! {
        btnAdvancedVolume
    }
    
    override var lblVolume: VALabel! {
        lblAdvancedVolume
    }
    
    override var volumeSlider: NSSlider! {
        advancedVolumeSlider
    }
    
    override func viewDidLoad() {
        
        btnVolume.tintFunction = {.white70Percent}
        btnVolume.reTint()
        
        super.viewDidLoad()
    }
    
    override func initSubscriptions() {
        
        messenger.subscribeAsync(to: .player_trackTransitioned, handler: trackTransitioned(_:),
                                 filter: {msg in msg.trackChanged})
        
        messenger.subscribe(to: .player_mute, handler: mute)
        messenger.subscribe(to: .player_unmute, handler: unmute)
        messenger.subscribe(to: .player_setVolume, handler: setVolume(to:))
    }
    
    override func changeControlsView(to newControlsView: PlayerControlsViewType) {}
}
