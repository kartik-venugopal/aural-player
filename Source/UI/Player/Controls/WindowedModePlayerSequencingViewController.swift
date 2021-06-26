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
        
        Messenger.subscribe(self, .player_setRepeatMode, self.setRepeatMode(_:))
        Messenger.subscribe(self, .player_setShuffleMode, self.setShuffleMode(_:))
        
        Messenger.subscribe(self, .applyTheme, self.applyTheme)
        Messenger.subscribe(self, .applyColorScheme, self.applyColorScheme(_:))
        Messenger.subscribe(self, .changeFunctionButtonColor, self.changeFunctionButtonColor(_:))
        Messenger.subscribe(self, .changeToggleButtonOffStateColor, self.changeToggleButtonOffStateColor(_:))
    }
    
    private func applyTheme() {
        applyColorScheme(colorSchemesManager.systemScheme)
    }
    
    private func applyColorScheme(_ scheme: ColorScheme) {
        redrawButtons()
    }
    
    private func changeFunctionButtonColor(_ color: NSColor) {
        redrawButtons()
    }
    
    private func changeToggleButtonOffStateColor(_ color: NSColor) {
        redrawButtons()
    }
    
    private func redrawButtons() {
        [btnRepeat, btnShuffle].forEach {$0.reTint()}
    }
}
