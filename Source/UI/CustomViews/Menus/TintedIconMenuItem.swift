//
//  TintedIconMenuItem.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    A special menu item (with an image) to which a tint can be applied, to conform to the current system color scheme.
 */
@IBDesignable
class TintedIconMenuItem: NSMenuItem, ColorSchemePropertyChangeReceiver {
    
    // A base image that is used as an image template.
    @IBInspectable var baseImage: NSImage?
    
    func colorChanged(_ newColor: NSColor) {
        image = baseImage?.tintedUsingCIFilterWithColor(newColor)
    }
}
