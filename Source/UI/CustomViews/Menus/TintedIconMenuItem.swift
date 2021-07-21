//
//  TintedIconMenuItem.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    A special menu item (with an image) to which a tint can be applied, to conform to the current system color scheme.
 */
@IBDesignable
class TintedIconMenuItem: NSMenuItem, Tintable {
    
    // A base image that is used as an image template.
    @IBInspectable var baseImage: NSImage? {
        didSet {reTint()}
    }
    
    // A function that produces a color used to tint the base image.
    var tintFunction: () -> NSColor = {Colors.functionButtonColor} {
        didSet {reTint()}
    }
    
    // Reapplies the tint (eg. when the tint color has changed or the base image has changed).
    func reTint() {
        self.image = self.baseImage?.filledWithColor(tintFunction())
    }
}
