//
//  VolumeButton.swift
//  Aural
//
//  Created by Kay Ven on 11/28/17.
//  Copyright © 2017 Anonymous. All rights reserved.
//

import Cocoa

@IBDesignable
class VolumeButton: NSButton {
    
    @IBOutlet weak var slider: NSSlider!
    @IBOutlet weak var volumeMenuItem: NSMenuItem!
    @IBOutlet weak var volumeMenu: NSMenu!
    
    private var autoHideSlider: AutoHidingMenu!
    
    override func awakeFromNib() {
        Swift.print("Awoke vol")
        
        let area = NSTrackingArea.init(rect: self.bounds, options: [NSTrackingAreaOptions.mouseEnteredAndExited, NSTrackingAreaOptions.activeAlways], owner: self, userInfo: nil)
        self.addTrackingArea(area)
        
        autoHideSlider = AutoHidingMenu(volumeMenu, volumeMenuItem, self, NSPoint(x: self.frame.width, y: 0), 1)
    }
    
    override func mouseEntered(with event: NSEvent) {
        Swift.print("Entered vol")
        autoHideSlider.showMenu()
    }
    
    override func mouseExited(with event: NSEvent) {
        Swift.print("Exited vol")
    }
}
