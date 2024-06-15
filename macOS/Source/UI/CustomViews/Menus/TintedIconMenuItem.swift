//
//  TintedIconMenuItem.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
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
    
    func colorChanged(_ newColor: PlatformColor) {
        image = baseImage?.tintedUsingCIFilterWithColor(newColor)
    }
}

class TintedSymbolMenuItem: NSMenuItem, ColorSchemePropertyChangeReceiver {
    
    // A base image that is used as an image template.
    @IBInspectable var baseImage: NSImage?
    
    func colorChanged(_ newColor: PlatformColor) {
        
        image = baseImage?.filledWithColor(newColor)
        
        if #available(macOS 12.0, *) {
            print(image?.symbolConfiguration.attributeKeys)
        }
    }
}
