//
//  MenuBarPlayerSequencingViewController.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

class MenuBarPlayerSequencingViewController: PlayerSequencingViewController {
    
    override func initSubscriptions() {}
    
    // When the buttons are in an "Off" state, they should be tinted according to the system color scheme's off state button color.
    override var offStateTintFunction: TintFunction {{.white40Percent}}
    
    // When the buttons are in an "On" state, they should be tinted according to the system color scheme's function button color.
    override var onStateTintFunction: TintFunction {{.white70Percent}}
}
