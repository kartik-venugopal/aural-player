//
//  MenuBarPlayerAudioViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class MenuBarPlayerAudioViewController: PlayerAudioViewController {
    
    override var showsPanControl: Bool {false}
    
    override func viewDidLoad() {
        
        btnVolume.tintFunction = {ColorConstants.white70Percent}
        btnVolume.reTint()
        
        super.viewDidLoad()
    }
    
    override func initSubscriptions() {
        
        messenger.subscribeAsync(to: .player_trackTransitioned, handler: trackTransitioned(_:),
                                 filter: {msg in msg.trackChanged})
    }
}
