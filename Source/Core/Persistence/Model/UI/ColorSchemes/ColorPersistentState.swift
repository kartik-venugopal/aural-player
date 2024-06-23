//
//  ColorPersistentState.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//

import Cocoa

///
/// Encapsulates persistent state for a single NSColor.
///
struct ColorPersistentState: Codable {
    
    // Gray, RGB, or CMYK
    let colorSpace: Int?
    let alpha: CGFloat?
    
    var white: CGFloat? = nil
    
    var red: CGFloat? = nil
    var green: CGFloat? = nil
    var blue: CGFloat? = nil
    
    var cyan: CGFloat? = nil
    var magenta: CGFloat? = nil
    var yellow: CGFloat? = nil
    var black: CGFloat? = nil
    
    private static let defaultAlpha: CGFloat = 1.0
    
    // Maps an NSColor to a ColorPersistentState object that can be persisted.
    init(color: NSColor) {
        
        self.colorSpace = color.colorSpace.colorSpaceModel.rawValue
        self.alpha = color.alphaComponent
        
        switch color.colorSpace.colorSpaceModel {
        
        case .gray:
            
            self.white = color.whiteComponent
            
        case .rgb:
            
            self.red = color.redComponent
            self.green = color.greenComponent
            self.blue = color.blueComponent
            
        case .cmyk:
            
            self.cyan = color.cyanComponent
            self.magenta = color.magentaComponent
            self.yellow = color.yellowComponent
            self.black = color.blackComponent
            
        default:
            
            self.white = color.whiteComponent
            
            self.red = color.redComponent
            self.green = color.greenComponent
            self.blue = color.blueComponent
            
            self.cyan = color.cyanComponent
            self.magenta = color.magentaComponent
            self.yellow = color.yellowComponent
            self.black = color.blackComponent
        }
    }
    
    // Dummy implementation (meant to be overriden).
    func toColor() -> NSColor? {
        
        guard let colorSpace = self.colorSpace else {return nil}
        
        switch colorSpace {
            
        case NSColorSpace.Model.gray.rawValue:
            
            guard let white = self.white else {return nil}
            return NSColor(white: white, alpha: alpha ?? Self.defaultAlpha)
            
        case NSColorSpace.Model.rgb.rawValue:
            
            guard let red = self.red, let green = self.green, let blue = self.blue else {return nil}
            return NSColor(red: red, green: green, blue: blue, alpha: alpha ?? Self.defaultAlpha)
            
        case NSColorSpace.Model.cmyk.rawValue:
            
            guard let cyan = self.cyan, let magenta = self.magenta, let yellow = self.yellow,
                  let black = self.black else {return nil}
            
            return NSColor(deviceCyan: cyan, magenta: magenta, yellow: yellow, black: black,
                           alpha: alpha ?? Self.defaultAlpha)
            
        default:
            
            return nil
        }
    }
}
