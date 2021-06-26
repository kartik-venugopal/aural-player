//
//  ControlBarModePlayerAudioViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class ControlBarModePlayerAudioViewController: PlayerAudioViewController {
    
    override var showsPanControl: Bool {false}
    
    override func viewDidLoad() {
        
        btnVolume.tintFunction = {Colors.functionButtonColor}
        btnVolume.reTint()
        
        super.viewDidLoad()
    }
    
    override func initSubscriptions() {
        
        Messenger.subscribeAsync(self, .player_trackTransitioned, self.trackTransitioned(_:),
                                 filter: {msg in msg.trackChanged},
                                 queue: .main)
    }
}
