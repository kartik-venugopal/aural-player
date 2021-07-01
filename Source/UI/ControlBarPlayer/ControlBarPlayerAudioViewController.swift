//
//  ControlBarPlayerAudioViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class ControlBarPlayerAudioViewController: PlayerAudioViewController {
    
    override var showsPanControl: Bool {false}
    
    override func viewDidLoad() {
        
        btnVolume.tintFunction = {Colors.functionButtonColor}
        lblVolume.textColor = Colors.functionButtonColor
        
        super.viewDidLoad()
    }
    
    override func initSubscriptions() {
        
        Messenger.subscribeAsync(self, .player_trackTransitioned, self.trackTransitioned(_:),
                                 filter: {msg in msg.trackChanged},
                                 queue: .main)
        
        Messenger.subscribe(self, .player_muteOrUnmute, self.muteOrUnmute)
        Messenger.subscribe(self, .player_decreaseVolume, self.decreaseVolume(_:))
        Messenger.subscribe(self, .player_increaseVolume, self.increaseVolume(_:))
        
        Messenger.subscribe(self, .applyTheme, self.applyTheme)
        Messenger.subscribe(self, .applyFontScheme, self.applyFontScheme(_:))
        Messenger.subscribe(self, .applyColorScheme, self.applyColorScheme(_:))
    }
}
