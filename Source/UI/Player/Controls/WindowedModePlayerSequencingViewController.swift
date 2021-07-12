//
//  WindowedModePlayerSequencingViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class WindowedModePlayerSequencingViewController: PlayerSequencingViewController {
    
    // When the buttons are in an "Off" state, they should be tinted according to the system color scheme's off state button color.
    override var offStateTintFunction: TintFunction {{Colors.toggleButtonOffStateColor}}
    
    // When the buttons are in an "On" state, they should be tinted according to the system color scheme's function button color.
    override var onStateTintFunction: TintFunction {{Colors.functionButtonColor}}
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        redrawButtons()
    }
    
    override func initSubscriptions() {
        
        messenger.subscribe(to: .player_setRepeatMode, handler: setRepeatMode(_:))
        messenger.subscribe(to: .player_setShuffleMode, handler: setShuffleMode(_:))
        
        messenger.subscribe(to: .applyTheme, handler: applyTheme)
        messenger.subscribe(to: .applyColorScheme, handler: applyColorScheme(_:))
        messenger.subscribe(to: .changeFunctionButtonColor, handler: changeFunctionButtonColor(_:))
        messenger.subscribe(to: .changeToggleButtonOffStateColor, handler: changeToggleButtonOffStateColor(_:))
    }
}
