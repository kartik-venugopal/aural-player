//
//  ToggleMenuItem.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    A menu item that is capable of switching (or "toggling") between two states, and displays a preset image/title corresponding to each state (example - add/remove favorites menu item)
 */
@IBDesignable
class ToggleMenuItem: NSMenuItem {
    
    // The image displayed when the button is in an "Off" state
    @IBInspectable var offImage: NSImage?
    
    // The image displayed when the button is in an "On" state
    @IBInspectable var onImage: NSImage?
    
    // The menu item's title when it is in an "Off" state
    @IBInspectable var offStateTitle: String!
    
    // The menu item's title when it is in an "On" state
    @IBInspectable var onStateTitle: String!
    
    private var _isOn: Bool = false
    
    // Sets the item state to be "Off"
    override func off() {
        
        self.title = offStateTitle
        self.image = offImage
        _isOn = false
    }
    
    // Sets the item state to be "On"
    override func on() {
        
        self.title = onStateTitle
        self.image = onImage
        _isOn = true
    }
    
    // Convenience function to set the item to "On" if the specified condition is true, and "Off" if not.
    override func onIf(_ condition: Bool) {
        condition ? on() : off()
    }
    
    // Toggles the On/Off state
    override func toggle() {
        _isOn ? off() : on()
    }
    
    // Returns true if the item is in the On state, false otherwise.
    override var isOn: Bool {
        _isOn
    }
    
    override var isOff: Bool {
        !_isOn
    }
}
